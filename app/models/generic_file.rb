require 'fileutils'

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Open3
  include GenericFileConcerns::Ftp

  has_metadata 'ffprobe', type: FfmpegDatastream
  has_metadata 'descMetadata', type: MediaAnnotationDatastream
  has_file_datastream "content", type: FileContentDatastream, control_group: 'E'

  delegate :has_location, to: 'descMetadata'

  before_destroy :remove_content

  def remove_content
    content.run_callbacks :destroy 
  end

  # Overridden to write the file into the external store instead of a datastream
  def add_file(file, dsid, file_name) 
    return add_external_file(file, dsid, file_name) if dsid == 'content'
    super
  end

  def add_external_file(file, dsid, file_name)
    path = File.join(directory, file_name)
    if file.respond_to? :read
      File.open(path, 'wb') do |f| 
        f.write file.read 
      end
    else
      # it's a filename.
      FileUtils.move(file, path)
    end
    
    content.dsLocation = URI.escape("file://#{path}")
    mime = MIME::Types.type_for(path).first
    content.mimeType = mime.content_type if mime # mime can't always be detected by filename
    set_title_and_label( file_name, :only_if_blank=>true )
    save!
  end

  # Overridden to load the original image from an external datastream
  def load_image_transformer
    Magick::ImageList.new(content.filename)
  end

  def directory
    dir_parts = noid.scan(/.{1,2}/)
    dir = File.join(Rails.configuration.external_store_base, dir_parts)
    puts "Making #{dir}"
    FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
    dir
  end  

  def log_events
    TrackingEvent.where(pid: pid)
  end

  def views
    log_events.where(event: 'view')
  end

  def downloads
    log_events.where(event: 'download')
  end

  def terms_for_editing
    terms_for_display -
     [:part_of, :date_modified, :date_uploaded, :format] # I'm not sure why resource_type would be excluded#, :resource_type]
  end

  def terms_for_display
    [ :part_of, :contributor, :creator, :title, :description, 
        :publisher, :date_created, :date_uploaded, :date_modified,:subject, :language, :rights, 
        :resource_type, :identifier, :has_location, :tag, :related_url]
  end
  
  ## Extract the metadata from the content datastream and record it in the characterization datastream
  def characterize
    fits_xml, ffprobe_xml = self.content.extract_metadata
    self.characterization.ng_xml = fits_xml
    fix_mxf_characterization!
    self.ffprobe.ng_xml = ffprobe_xml
    self.append_metadata
    self.filename = self.label
    save unless self.new_object?
  end


  # The present version of fits.sh (0.6.1) doesn't set a mime-type for MXF files
  # this method rectifies that until a fixed version of fits.sh is released.
  def fix_mxf_characterization!
    self.characterization.mime_type = 'application/mxf' if mime_type == 'application/octet-stream' && format_label == ["Material Exchange Format"]
  end

  ### Map  location[].locationName -> based_near[]
  def based_near
    descMetadata.has_location #.map(&:location_name).flatten
  end

  ### Map creator[] -> creator[].name
  # @param [Array,String] creator_properties a list of hashes with role and name or just names
  def creator=(creator_properties)
    assign_member_with_name_and_role(:creator, creator_properties)
  end

  ### Map contributor[] -> contributor[].name
  # @param [Array,String] contributor_properties a list of hashes with role and name or just names
  def contributor=(contributor_properties)
    assign_member_with_name_and_role(:contributor, contributor_properties)
  end

  ### Map publisher[] -> publisher[].name
  # @param [Array,String] publisher_properties a list of hashes with role and name or just names
  def publisher=(publisher_properties)
    assign_member_with_name_and_role(:publisher, publisher_properties)
  end

  ### Map based_near[] -> has_location[].locationName
  # @param [Array] vals a list of hashes with location_name
  def has_location=(vals)
    existing = descMetadata.has_location
    descMetadata.has_location = [] if existing.size > vals.size
    Array(vals).each_with_index do |val, index|
      obj = descMetadata.has_location[index]
      if obj.nil?
        obj = descMetadata.has_location.build
      end
      obj.location_name = val['location_name']
    end
  end

  def to_pbcore_xml
    doc = HydraPbcore::Datastream::Document.new
    doc.title = title[0]
    doc.alternative_title = title[1]
    descMetadata.creator.each do |c|
      doc.insert_creator c.name.first, c.role.first
    end
    descMetadata.contributor.each do |c|
      doc.insert_contributor c.name.first, c.role.first
    end
    descMetadata.publisher.each do |c|
      doc.insert_publisher c.name.first, c.role.first
    end
    descMetadata.has_location.each do |l|
      doc.insert_place l.location_name.first
    end

    doc.insert_date(date_created.first)
    doc.asset_type = resource_type.to_a


    instantiation = Nokogiri::XML::Builder.new do |xml|
      xml.root {
        xml.pbcoreInstantiation {
          xml.instantiationIdentifier {
            xml.text noid
          }
          xml.instantiationLocation {
            xml.text content.filename
          }
          # xml.instantiationDate(:dateType=>"created")
          # xml.instantiationDigital(:source=>"EBU file formats")
          if video?
            xml.instantiationMediaType(:source=>"PBCore instantiationMediaType") {
              xml.text "Moving Image"
            }
          elsif audio?
            xml.instantiationMediaType(:source=>"PBCore instantiationMediaType") {
              xml.text "Sound"
            }
          end
          # xml.instantiationGenerations(:source=>"PBCore instantiationGenerations")
          xml.instantiationFileSize(:unitsOfMeasure=>"") {
            xml.text file_size.first
          }
          xml.instantiationDuration {
            xml.text ffprobe.duration.first
          }
          # xml.instantiationColors(:source=>"PBCore instantiationColors") {
          #   xml.text "Color"
          # }

          0.upto(ffprobe.streams.stream.count - 1).each do |n|
            stream = ffprobe.streams.stream(n)
            xml.instantiationEssenceTrack {
              xml.essenceTrackType {
                xml.text stream.codec_type.first.capitalize if stream.codec_type.present?
              }
              xml.essenceTrackDataRate(:unitsOfMeasure=>"bps") {
                xml.text stream.bit_rate.first
              }
              xml.essenceTrackStandard {
                xml.text case stream.codec_long_name.first
                  when "H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10"
                    "H.264/MPEG-4 AVC"
                  else
                    stream.codec_name.first.upcase
                  end
              }
              xml.essenceTrackEncoding(:source=>"PBCore essenceTrackEncoding")
              if stream.codec_type.first == 'video'
                xml.essenceTrackFrameRate(:unitsOfMeasure=>"fps") {
                  xml.text stream.frame_rate.first
                }
                xml.essenceTrackFrameSize(:source=>"PBCore essenceTrackFrameSize") {
                  xml.text "#{stream.width.first}x#{stream.height.first}"
                }
                xml.essenceTrackAspectRatio(:source=>"PBCore essenceTrackAspectRatio")
              elsif stream.codec_type.first == 'audio'
                xml.essenceTrackSamplingRate(:unitsOfMeasure=>"hz") {
                  xml.text stream.sample_rate.first
                }
                xml.essenceTrackBitDepth {
                  xml.text stream.bits_per_sample.first
                }
                xml.essenceTrackAnnotation(:annotationType=>"Number of Audio Channels") {
                  xml.text stream.channels.first
                }
              end
            }
          end

          xml.instantiationRights {
            xml.rightsSummary
          }
          
        }
      }
    end.doc

    
    doc.ng_xml.root.add_child instantiation.root.children

    doc.to_xml

  end

  private 
  def assign_member_with_name_and_role(field, values)
    existing = descMetadata.send field
    descMetadata.send(field.to_s + '=', []) if existing.size > values.size
    Array(values).each_with_index do |val, index|
      obj = existing[index]
      if obj.nil?
        obj = existing.build
      end
      if (val.kind_of? String) 
        obj.name = val
      else
        obj.name = val['name']
        obj.role = val['role']
      end
    end
  end


end
