class ImportedMetadata < ActiveFedora::Base
  include Sufia::ModelMethods
  include Sufia::Noid
  include Sufia::GenericFile::Permissions
  has_metadata :name => "properties", :type => PropertiesDatastream
  has_metadata 'descMetadata', type: ImportPbcoreDatastream
  
  delegate_to :properties, [:relative_path, :depositor, :import_url], :unique => true
  delegate_to :descMetadata, [:item_title, :episode_title, :program_title, 
                              :series_title, :filenames, :description,
                              :event_location, :date_portrayed,
                              :drive_name, :folder_name], :unique => true

  attr_accessor :apply_to

  after_initialize :init

  def init
    self.apply_to = []
  end

  def apply!
    raise "Must save ImportedMetadata before calling apply!" if new_object?
    template = metadata_as_template
    apply_to.each do |file_pid|
      Sufia.queue.push(ApplyTemplateJob.new(depositor, file_pid, metadata_as_template))
    end
  end
  
  def metadata_as_template
    {'title_attributes' =>[
       {'title_type' => 'Series', 'value' => series_title},
       {'title_type' => 'Program', 'value' => program_title},
       {'title_type' => 'Episode', 'value' => episode_title},
       {'title_type' => 'Item', 'value' => item_title},
     ],
     'description_attributes' => [
       {'type' => 'Log', 'value' => description},
     ],
     'has_location_attributes' => [
       {'location_name' => event_location},
     ],
     'has_event_attributes' => [
       {'date_time' => date_portrayed},
     ],
     'applied_template_id' => pid, 'unarranged' => 'false'
    }.with_indifferent_access
  end

  def terms_for_display
    [:item_title, :episode_title, :program_title, :series_title, :description, :filenames, :drive_name, :folder_name]
  end

  def terms_for_editing
    [:item_title, :episode_title, :program_title, :series_title, :filenames, :drive_name, :folder_name, :description]

  end
  
  def match_files_with_path
    "#{drive_name}/#{folder_name}"
  end
  
  def matching_files
    GenericFile.to_enum(:find_each, "_query_:\"{!raw f=relative_path}#{match_files_with_path}\"").to_a
  end
end
