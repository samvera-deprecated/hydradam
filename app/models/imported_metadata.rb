class ImportedMetadata < ActiveFedora::Base
  include Sufia::ModelMethods
  include Sufia::Noid
  include Sufia::GenericFile::Permissions
  # include Sufia::GenericFile::WebForm
  # has_metadata 'templateMetadata', type: HydraPbcore::Datastream::Document
  has_metadata :name => "properties", :type => PropertiesDatastream
  has_metadata 'descMetadata', type: MediaAnnotationDatastream
  
  delegate_to :properties, [:relative_path, :depositor, :import_url], :unique => true
  
end