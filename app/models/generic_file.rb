require 'fileutils'

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Open3
  include GenericFileConcerns::Ftp

  has_metadata 'ffprobe', type: FfmpegDatastream
  has_metadata 'descMetadata', type: MediaAnnotationDatastream
  has_file_datastream "content", type: FileContentDatastream, control_group: 'E'

  delegate_to 'descMetadata', [:has_location, :program_title, :series_title,
                               :item_title, :episode_title,
                               :creator_attributes, :contributor_attributes, 
                               :publisher_attributes, :has_location_attributes,
                               :description_attributes, :title_attributes]

  delegate_to 'properties', [:unarranged, :applied_template_id], unique: true

  attr_accessible  :part_of, :contributor_attributes, :creator_attributes,
        :title_attributes, :description_attributes, :publisher_attributes,
        :date_created, :date_uploaded, :date_modified, :subject, :language,
        :rights, :resource_type, :identifier, :has_location_attributes, :tag,
        :related_url, :permissions

  before_destroy :remove_content

  def remove_content
    content.run_callbacks :destroy 
  end

  # overriding this method to initialize more complex RDF assertions (b-nodes)
  def initialize_fields
    publisher.build if publisher.empty?
    contributor.build if contributor.empty?
    creator.build if creator.empty?
    has_location.build if has_location.empty?
    description.build if description.empty?
    super
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
    title = self.title.build(value: file_name, title_type: 'Program')
    self.label = file_name
    save!
  end

  # Overridden to check that mxf actually has video tracks 
  def video?
    if mime_type == 'application/mxf'
      ffprobe.codec_type.any? {|type| type == 'video'}
    else
      super
    end
  end

  # If the mxf has no video tracks return true   
  def audio?
    if mime_type == 'application/mxf'
      !ffprobe.codec_type.any? {|type| type == 'video'}
    else
      super
    end
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
        :publisher, :date_created, :date_uploaded, :date_modified, :subject, :language, :rights, 
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
  def creator=(args)
    unless args.is_a?(String) || args.is_a?(Array)
      raise ArgumentError, "You must provide a string or an array.  You provided #{args.inspect}"
    end
    args = Array(args)
    self.creator_attributes = [{name: args, role: "Uploader"}]
  end

  ### Map title[] -> title[].value
  # @param [Array,String] title_properties a list of hashes with type and value
  def title=(args)
    unless args.is_a?(String) || args.is_a?(Array)
      raise ArgumentError, "You must provide a string or an array.  You provided #{args.inspect}"
    end
    args = Array(args)
    self.title_attributes = [{name: args, title_type: "Program"}]
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

  # normally if you want to remove exising nested params you pass:
  #   {:_delete => true, :id => '_:g1231011230128'}
  # since the editor doesn't know about that, we just delete
  # all nested objects if they will be replaced.
  def destroy_existing_nested_nodes(params)
    self.creator.each { |c| c.destroy } if params[:creator_attributes]
    self.contributor.each { |c| c.destroy } if params[:contributor_attributes]
    self.producer.each { |c| c.destroy } if params[:producer_attributes]
    self.title.each { |c| c.destroy } if params[:title_attributes]
  end


  def to_s
    val = [program_title.first, series_title.first].compact.join(' | ')
    val.empty? ? label : val 
  end

  def to_pbcore_xml
    doc = HydraPbcore::Datastream::Document.new
    doc.title = program_title
    doc.alternative_title = series_title
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

end
