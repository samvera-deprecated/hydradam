class MediaAnnotationDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.part_of(:to => "isPartOf", :in => RDF::EbuCore)
  
    map.contributor(:in=> RDF::EbuCore, :to=>'hasContributor', :class_name=>'Person')
    map.creator(:in=> RDF::EbuCore, :to=>'hasCreator', :class_name=>'Person')
    map.publisher(:in=> RDF::EbuCore, :to=>'hasPublisher', :class_name=>'Person')
    #map.publication_events(:in=> RDF::EbuCore, :to=>'hasPublicationEvent', :class_name=>'Event')
    map.video_tracks(:in=> RDF::EbuCore, :to=>'hasVideoTrack', :class_name=>'Video')

    # TODO the whole thing is a MediaResource - add filename, fileByteSize, hasFormat
    # TODO to video tracks add bitRate

    # location is already defined as a method name on Datastream, so we use has_location
    map.has_location(:in => RDF::EbuCore, :to=>'hasLocation', :class_name=>'Location')

    map.title(:in => RDF::EbuCore) do |index|
      index.as :stored_searchable
    end
    map.date_uploaded(:to => "dateSubmitted", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_searchable, :sortable
    end

    map.date_modified(:to => "dateModified", :in => RDF::EbuCore) do |index|
      index.type :date
      index.as :stored_searchable, :sortable
    end
    map.date_created(:in => RDF::EbuCore, :to => 'dateCreated') do |index|
      index.as :stored_searchable
    end

    map.format(:in => RDF::EbuCore, :to=>'hasFormat') do |index|
      index.as :stored_searchable
    end

    map.subject(:in => RDF::EbuCore, :to=>'hasSubject') do |index|
      index.as :stored_searchable
    end
    map.keyword(:in => RDF::EbuCore, :to=>'hasKeyword') do |index|
      index.as :stored_searchable
    end
    map.summary(:in => RDF::EbuCore) do |index|
      index.as :stored_searchable
    end
    map.description(:in => RDF::EbuCore) do |index|
      index.as :stored_searchable
    end
    map.duration(:in => RDF::EbuCore) do |index|
      index.as :stored_searchable
    end

    map.rights(:in => RDF::EbuCore, :to=>'rightsExpression') do |index|
      index.as :stored_searchable
    end
    map.resource_type(:to => "hasObjectType", :in => RDF::EbuCore) do |index|
      index.as :stored_searchable, :facetable
    end

    map.identifier(:in => RDF::EbuCore) do |index|
      index.as :stored_searchable
    end

    map.language(:in => RDF::EbuCore, :to=>'hasLanguage') do |index|
      index.as :stored_searchable, :facetable
    end


    map.tag(:to => "isRelatedTo", :in => RDF::EbuCore) do |index|
      index.as :stored_searchable, :facetable
    end

    map.related_url(:to => "seeAlso", :in => RDF::RDFS)
    
  end
  class Person
    include ActiveFedora::RdfObject
    rdf_type 'http://www.ebu.ch/metadata/ontologies/ebucore#Person'
    map_predicates do |map|
      map.name(:in => RDF::EbuCore) do |index|
        index.as :stored_searchable
      end
      map.role(:in => RDF::EbuCore, :to=>'hasRole') 
    end
  end

  class Location
    include ActiveFedora::RdfObject
    rdf_type 'http://www.ebu.ch/metadata/ontologies/ebucore#Location'
    map_predicates do |map|
      map.location_name(:in => RDF::EbuCore, :to=>'locationName') do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end

  LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
  LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
  LocalAuthority.register_vocabulary(self, "tag", "lc_genres")

  def to_solr(solr_doc = {})
    solr_doc = super
    creators = self.creator.map { |c| c.name }.flatten
    store_in_solr_doc(solr_doc, 'creator', creators, [:stored_searchable, type: :text], :facetable)

    contributors = self.contributor.map { |c| c.name }.flatten
    store_in_solr_doc(solr_doc, 'contributor', contributors, [:stored_searchable, type: :text], :facetable)

    publishers = self.publisher.map { |c| c.name }.flatten
    store_in_solr_doc(solr_doc, 'publisher', publishers, [:stored_searchable, type: :text], :facetable)

    based_near = self.has_location.map { |c| c.location_name }.flatten
    store_in_solr_doc(solr_doc, 'based_near', based_near, [:stored_searchable, type: :text], :facetable)

    solr_doc
  end

  def store_in_solr_doc(solr_doc, name, value, *types)
    types.each do |type|
      solr_doc[ActiveFedora::SolrService.solr_name(prefix(name), *type)] = value
    end
  end
end
