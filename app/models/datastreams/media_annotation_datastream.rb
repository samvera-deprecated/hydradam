class MediaAnnotationDatastream < ActiveFedora::NtriplesRDFDatastream
  rdf_type RDF::EbuCore.MediaResource
  map_predicates do |map|
    map.part_of(:to => "isPartOf", :in => RDF::EbuCore)
  
    map.contributor(:in=> RDF::EbuCore, :to=>'hasContributor', :class_name=>'Person')
    map.creator(:in=> RDF::EbuCore, :to=>'hasCreator', :class_name=>'Person')
    map.publisher(:in=> RDF::EbuCore, :to=>'hasPublisher', :class_name=>'Person')
    #map.publication_events(:in=> RDF::EbuCore, :to=>'hasPublicationEvent', :class_name=>'Event')
    map.video_tracks(:in=> RDF::EbuCore, :to=>'hasVideoTrack', :class_name=>'Video')
    map.description(in: RDF::EbuCore, :class_name=>'Description')

    map.title(:in=> RDF::DC, :class_name=>'Title')

    map.has_event(:in => RDF::EbuCore, :to=>'hasCoverage', :class_name=>'Event')
    map.has_depicted_event(:in => RDF::EbuCore, :to=>'hasCoverage', :class_name=>'DepictedEvent')

    map.date_uploaded(:to => "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_modified(:to => "dateModified", in: RDF::EbuCore) do |index|
      index.type :date
      index.as :stored_sortable
    end
    map.date_created(in: RDF::EbuCore, :to => 'dateCreated') do |index|
      index.as :stored_searchable
    end

    map.filename(in: RDF::EbuCore)
    map.fileByteSize(in: RDF::EbuCore)

    # This is "Media" (e.g. Moving Image, Text, Static Image)
    map.format(in: RDF::EbuCore, :to=>'hasFormat') do |index|
      index.as :stored_searchable
    end

    map.subject(in: RDF::EbuCore, :to=>'hasSubject') do |index|
      index.as :stored_searchable
    end
    map.keyword(in: RDF::EbuCore, :to=>'hasKeyword') do |index|
      index.as :stored_searchable
    end
    map.summary(in: RDF::EbuCore) do |index|
      index.as :stored_searchable
    end
    map.duration(in: RDF::EbuCore) do |index|
      index.as :stored_searchable
    end

    map.rights(:in => RDF::EbuCore, :to=>'rightsExpression') do |index|
      index.as :stored_searchable
    end
    map.resource_type(:to => "hasObjectType",in: RDF::EbuCore) do |index|
      index.as :stored_searchable, :facetable
    end

    map.has_source(:to => "hasSource",in: RDF::EbuCore, class_name: 'Resource')

    map.identifier(in: RDF::EbuCore) do |index|
      index.as :stored_searchable
    end

    map.language(in: RDF::EbuCore, :to=>'hasLanguage') do |index|
      index.as :stored_searchable, :facetable
    end


    map.tag(:to => "isRelatedTo", in: RDF::EbuCore) do |index|
      index.as :stored_searchable, :facetable
    end

    map.related_url(:to => "seeAlso", in: RDF::RDFS)
    
  end

  accepts_nested_attributes_for :title, :creator, :contributor, :publisher, :description, :has_location, :has_event

  class Title
    include ActiveFedora::RdfObject
    map_predicates do |map|
      map.value(in: RDF, to: 'value') do |index|
        index.as :stored_searchable
      end
      map.title_type(in: RDF::PBCore, to: 'titleType') 
    end
  end

  class Description
    include ActiveFedora::RdfObject
    map_predicates do |map|
      map.value(in: RDF, to: 'value') do |index|
        index.as :stored_searchable
      end
      map.type(in: RDF::PBCore, to: 'titleType') 
    end
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
    rdf_type RDF::EbuCore.Location
    map_predicates do |map|
      map.location_name(:in => RDF::EbuCore, :to=>'locationName') do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end

  class Event
    include ActiveFedora::RdfObject
    rdf_type RDF::PBCore.Event
    map_predicates do |map|
      map.event_name(:in => RDF::EbuCore, :to=>'eventName')
      map.event_definition(:in => RDF::EbuCore, :to=>'eventDefinition')
      map.date_time(:in => RDF::EbuCore, :to=>'dateTime')
      map.has_location(in: RDF::EbuCore, to: 'hasLocation', class_name: "Location")
    end
    accepts_nested_attributes_for :has_location
  end

  class DepictedEvent
    include ActiveFedora::RdfObject
    rdf_type RDF::PBCore.DepictedEvent
    map_predicates do |map|
      map.date_time(:in => RDF::EbuCore, :to=>'dateTime')
    end
  end

  class Resource
    include ActiveFedora::RdfObject
    rdf_type RDF::PBCore.Resource
    map_predicates do |map|
      map.description(:in => RDF::EbuCore)
      map.identifier(:in => RDF::EbuCore)
    end
  end

  LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
  LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
  LocalAuthority.register_vocabulary(self, "tag", "lc_genres")

  # finds or creates an Event node where eventDefinition = Filming 
  def filming_event
    has_event.find {|e| e.event_definition.first == 'Filming'} || has_event.build(event_definition: 'Filming')
  end

  # finds or creates an Event node where eventDefinition = Production 
  def production_event
    has_event.find {|e| e.event_definition.first == 'Production'} || has_event.build(event_definition: 'Production')
  end

  # Set the location for a filming_event
  def event_location= location_names
    filming_event.has_location = []
    location_names.each do |name|
      filming_event.has_location.build(location_name: name)
    end
  end

  # required to stand in for GenericFile#remove_blank_assertions
  def event_location
    has_event.select {|e| e.event_definition.first == 'Filming'}
  end

  # Set the location for a production_event
  def production_location= location_names
    production_event.has_location = []
    location_names.each do |name|
      production_event.has_location.build(location_name: name)
    end
  end


  # required to stand in for GenericFile#remove_blank_assertions
  def production_location
    has_event.select {|e| e.event_definition.first == 'Production'}
  end

  def date_portrayed
    has_depicted_event.first ? has_depicted_event.first.date_time : []
  end

  def date_portrayed= date_val
    depicted_event = has_depicted_event.first || has_depicted_event.build
    depicted_event.date_time = date_val
  end

  def source
    has_source.first ? has_source.first.description : []
  end

  def source= val
    src = has_source.first || has_source.build
    src.description = val
  end

  def source_reference
    has_source.first ? has_source.first.identifier : []
  end

  def source_reference= val
    src = has_source.first || has_source.build
    src.identifier = val
  end


  def to_solr(solr_doc = {})
    solr_doc = super
    creators = self.creator.map { |c| c.name }.flatten
    store_in_solr_doc(solr_doc, 'creator', creators, [:stored_searchable, type: :text], :facetable)

    contributors = self.contributor.map { |c| c.name }.flatten
    store_in_solr_doc(solr_doc, 'contributor', contributors, [:stored_searchable, type: :text], :facetable)

    publishers = self.publisher.map { |c| c.name }.flatten
    store_in_solr_doc(solr_doc, 'publisher', publishers, [:stored_searchable, type: :text], :facetable)

    # based_near = self.has_location.map { |c| c.location_name }.flatten
    # store_in_solr_doc(solr_doc, 'based_near', based_near, [:stored_searchable, type: :text], :facetable)

    self.description.each do |t|
      store_in_solr_doc(solr_doc, "description", t.value, [:stored_searchable, type: :text])
    end
    self.title.each do |t|
      if t.title_type.first
        store_in_solr_doc(solr_doc, "#{t.title_type.first.downcase}_title", t.value, [:stored_searchable, type: :text])
      end
    end

    solr_doc
  end

  def store_in_solr_doc(solr_doc, name, value, *types)
    types.each do |type|
      solr_doc[ActiveFedora::SolrService.solr_name(prefix(name), *type)] = value
    end
  end

  def program_title
    find_title('Program')
  end

  def series_title
    find_title('Series')
  end

  def item_title
    find_title('Item')
  end

  def episode_title
    find_title('Episode')
  end

  def find_title(type)
    self.title.reduce([]) do |acc, t|
      acc += t.value if t.title_type.first == type
      acc
    end
  end
end
