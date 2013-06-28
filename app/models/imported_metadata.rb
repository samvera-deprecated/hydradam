class ImportedMetadata < ActiveFedora::Base
  include Sufia::ModelMethods
  include Sufia::Noid
  include Sufia::GenericFile::Permissions
  # include Sufia::GenericFile::WebForm
  # has_metadata 'templateMetadata', type: HydraPbcore::Datastream::Document
  has_metadata :name => "properties", :type => PropertiesDatastream
  has_metadata 'descMetadata', type: ImportPbcoreDatastream
  
  delegate_to :properties, [:relative_path, :depositor, :import_url], :unique => true
  delegate_to :descMetadata, [:item_title, :episode_title, :program_title, :series_title, :filenames, :description, :drive_name, :folder_name], :unique => true
  
  def terms_for_display
    [:item_title, :episode_title, :program_title, :series_title, :filenames]
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
