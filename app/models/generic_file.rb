require 'fileutils'

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Open3

  has_metadata 'ffprobe', type: FfmpegDatastream
  has_metadata 'descMetadata', :type => MediaAnnotationDatastream
  has_file_datastream :name => "content", :type => FileContentDatastream, :control_group=>'E'

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
    content.mimeType = MIME::Types.type_for(path).first.content_type
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
     [:part_of, :date_modified, :date_uploaded, :format, :resource_type]
  end

  def terms_for_display
    [ :part_of, :contributor, :creator, :title, :description, 
        :publisher, :date_created, :date_uploaded, :date_modified,:subject, :language, :rights, 
        :resource_type, :identifier, :based_near, :tag, :related_url]
  end
  
  ## Extract the metadata from the content datastream and record it in the characterization datastream
  def characterize
    fits_xml, ffprobe_xml = self.content.extract_metadata
    self.characterization.ng_xml = fits_xml
    self.ffprobe.ng_xml = ffprobe_xml
    self.append_metadata
    self.filename = self.label
    save unless self.new_object?
  end

  ### Map  creator[].name -> creator[]
  def creator
    descMetadata.creator.map(&:name).flatten
  end

  ### Map  contributor[].name -> contributor[]
  def contributor
    descMetadata.contributor.map(&:name).flatten
  end

  ### Map  publisher[].name -> publisher[]
  def publisher
    descMetadata.publisher.map(&:name).flatten
  end

  ### Map  location[].locationName -> based_near[]
  def based_near
    descMetadata.has_location.map(&:location_name).flatten
  end

  ### Map creator[] -> creator[].name
  def creator=(creator_names)
    existing_creators = descMetadata.creator
    descMetadata.creator = [] if existing_creators.size > creator_names.size
    Array(creator_names).each_with_index do |name, index|
      creator = descMetadata.creator[index]
      if creator.nil?
        creator = descMetadata.creator.build
      end
      creator.name = name
    end
  end

  ### Map contributor[] -> contributor[].name
  def contributor=(contributor_names)
    existing_contributors = descMetadata.contributor
    descMetadata.contributor = [] if existing_contributors.size > contributor_names.size
    Array(contributor_names).each_with_index do |name, index|
      contributor = descMetadata.contributor[index]
      if contributor.nil?
        contributor = descMetadata.contributor.build
      end
      contributor.name = name
    end
  end

  ### Map publisher[] -> publisher[].name
  def publisher=(names)
    existing = descMetadata.publisher
    descMetadata.publisher = [] if existing.size > names.size
    Array(names).each_with_index do |name, index|
      obj = descMetadata.publisher[index]
      if obj.nil?
        obj = descMetadata.publisher.build
      end
      obj.name = name
    end
  end

  ### Map based_near[] -> has_location[].locationName
  def based_near=(names)
    existing = descMetadata.has_location
    descMetadata.has_location = [] if existing.size > names.size
    Array(names).each_with_index do |name, index|
      obj = descMetadata.has_location[index]
      if obj.nil?
        obj = descMetadata.has_location.build
      end
      obj.location_name = name
    end
  end

  def to_pbcore_xml
    doc = HydraPbcore::Datastream::Document.new
    doc.main_title = title[0]
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

    doc.to_xml

  end

end
