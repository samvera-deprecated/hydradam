class MediaAnnotationDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.part_of(:to => "isPartOf", :in => RDF::EbuCore)
  
    map.contributor(:in=> RDF::EbuCore, :to=>'hasContributor', :class_name=>'Person')
    map.creator(:in=> RDF::EbuCore, :to=>'hasCreator', :class_name=>'Person')
    map.publication_events(:in=> RDF::EbuCore, :to=>'hasPublicationEvent', :class_name=>'Event')
    map.video_tracks(:in=> RDF::EbuCore, :to=>'hasVideoTrack', :class_name=>'Video')

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

    map.publisher(:in => RDF::EbuCore, :to=>'hasPublisher') do |index|
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

    map.based_near(:in => RDF::FOAF) do |index|
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

  after_initialize :default_values

  def default_values
    self.format = "Video" unless self.format.present?
  end

  LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
  LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
  LocalAuthority.register_vocabulary(self, "tag", "lc_genres")

  def to_solr(solr_doc = {})
    solr_doc = super
    creators = self.creator.map { |c| c.name }.flatten
    solr_doc[ActiveFedora::SolrService.solr_name(prefix('creator'), :stored_searchable, type: :text)] = solr_doc[ActiveFedora::SolrService.solr_name(prefix('creator'), :facetable)] = creators
    contributors = self.contributor.map { |c| c.name }.flatten
    solr_doc[ActiveFedora::SolrService.solr_name(prefix('contributor'), :stored_searchable, type: :text)] = solr_doc[ActiveFedora::SolrService.solr_name(prefix('contributor'), :facetable)] = contributors
    solr_doc
  end
end
