class MediaAnnotationDatastream < RDF::EbuCore::Datastream
  class Identifier < ActiveFedora::Rdf::Resource
    property :value, predicate: RDF.value
    property :identifier_type, predicate: RDF::WGBH.identifierType
  end
end