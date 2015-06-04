class MediaAnnotationDatastream < RDF::EbuCore::Datastream
  class Description < ActiveFedora::Rdf::Resource
    property :value, predicate: RDF.value do |index|
      index.as :stored_searchable
    end
    property :type, predicate: RDF::PBCore.titleType
  end
end