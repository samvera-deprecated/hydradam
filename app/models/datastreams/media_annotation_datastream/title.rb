class MediaAnnotationDatastream < RDF::EbuCore::Datastream
  class Title < ActiveFedora::Rdf::Resource
    property :value, predicate: RDF.value do |index|
      index.as :stored_searchable
    end

    property :title_type, predicate: RDF::PBCore.titleType

    def inspect
      "#<Title @value=\"#{value}\">"
    end
  end
end