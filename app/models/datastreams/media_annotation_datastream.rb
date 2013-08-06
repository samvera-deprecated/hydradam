class MediaAnnotationDatastream < ActiveFedora::NtriplesRDFDatastream
  rdf_type RDF::EbuCore.MediaResource
  map_predicates do |map|
    map.part_of(:to => "isPartOf", :in => RDF::EbuCore)
  
    map.contributor(:in=> RDF::EbuCore, :to=>'hasContributor', :class_name=>'Person')
    map.creator(:in=> RDF::EbuCore, :to=>'hasCreator', :class_name=>'Person')
    map.publisher(:in=> RDF::EbuCore, :to=>'hasPublisher', :class_name=>'Person')
    #map.publication_events(:in=> RDF::EbuCore, :to=>'hasPublicationEvent', :class_name=>'Event')
    map.video_tracks(:in=> RDF::EbuCore, :to=>'hasVideoTrack', :class_name=>'VideoTrack')
    map.description(in: RDF::EbuCore, :class_name=>'Description')

    map.title(:in=> RDF::DC, :class_name=>'Title')

    map.has_event(:in => RDF::EbuCore, :to=>'hasCoverage', :class_name=>'Event')
    map.has_depicted_event(:in => RDF::EbuCore, :to=>'hasCoverage', :class_name=>'DepictedEvent')

    map.is_covered_by(in: RDF::EbuCore, to: 'isCoveredBy', class_name: 'Rights')

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

    map.rights(in: RDF::EbuCore, to: 'rightsExpression') do |index|
      index.as :stored_searchable
    end
    map.resource_type(to: "hasObjectType", in: RDF::EbuCore) do |index|
      index.as :stored_searchable, :facetable
    end

    map.has_source(to: "hasSource", in: RDF::EbuCore, class_name: 'Resource')

    map.related_publication_event(to: "relatedPublicationEvent", in: RDF::EbuCore, class_name: 'PublicationEvent')

    map.identifier(in: RDF::EbuCore) do |index|
      index.as :stored_searchable
    end

    map.language(in: RDF::EbuCore, :to=>'hasLanguage') do |index|
      index.as :stored_searchable, :facetable
    end


    map.tag(to: "isRelatedTo", in: RDF::EbuCore) do |index|
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
    rdf_type RDF::EbuCore.Person
    map_predicates do |map|
      map.name(in: RDF::EbuCore) do |index|
        index.as :stored_searchable
      end
      map.role(in: RDF::EbuCore, to: 'hasRole') 
    end
  end

  class Agent
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.Agent
    map_predicates do |map|
      map.name(in: RDF::EbuCore) do |index|
        index.as :stored_searchable
      end
    end
  end

  class Location
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.Location
    map_predicates do |map|
      map.location_name(in: RDF::EbuCore, to: 'locationName') do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end

  class Event
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.Event
    map_predicates do |map|
      map.event_name(in: RDF::EbuCore, to: 'eventName')
      map.event_definition(in: RDF::EbuCore, to: 'eventDefinition')
      map.date_time(in: RDF::EbuCore, to: 'dateTime')
      map.has_location(in: RDF::EbuCore, to: 'hasLocation', class_name: "Location")
    end
    accepts_nested_attributes_for :has_location
  end

  class Rights
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.Rights
    map_predicates do |map|
      map.rights_expression(in: RDF::EbuCore, to: 'rightsExpression')
      map.has_rights_holder(in: RDF::EbuCore, to: 'hasRightsHolder', class_name: "Agent")
    end
  end

  class DepictedEvent
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.DepictedEvent
    map_predicates do |map|
      map.date_time(in: RDF::EbuCore, to: 'dateTime')
    end
  end

  class PublicationEvent
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.PublicationEvent
    map_predicates do |map|
      map.start_date_time(in: RDF::EbuCore, to: 'publishedStartDateTime')
      map.end_date_time(in: RDF::EbuCore, to: 'publishedEndDateTime')
      map.name(in: RDF::EbuCore, to: 'publicationEventName')
    end
  end

  class Resource
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.Resource
    map_predicates do |map|
      map.description(:in => RDF::EbuCore)
      map.identifier(:in => RDF::EbuCore)
    end
  end

  class VideoTrack
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.VideoTrack
    map_predicates do |map|
      map.frame_rate(in: RDF::EbuCore, to: 'hasFormat') #type is double
      map.format(in: RDF::EbuCore, to: 'hasFormat', class_name: 'VideoFormat')
    end
  end

  class VideoFormat
    include ActiveFedora::RdfObject
    rdf_type RDF::EbuCore.VideoFormat
    map_predicates do |map|
      map.aspect_ratio(in: RDF::EbuCore, to: 'aspectRatio')
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
    return unless location_names
    filming_event.has_location = []
    location_names.each do |name|
      filming_event.has_location.build(location_name: name)
    end
  end

  def event_location
    has_event.select {|e| e.event_definition.first == 'Filming'}.
      map {|e| e.has_location.
           map{ |l| l.location_name}}.flatten || []
  end

  # Set the location for a production_event
  def production_location= location_names
    return unless location_names
    production_event.has_location = []
    location_names.each do |name|
      production_event.has_location.build(location_name: name)
    end
  end

  def production_location
    has_event.select {|e| e.event_definition.first == 'Production'}.map {|e| e.has_location.map{ |l| l.location_name}}.flatten || []
  end

  def date_portrayed
    has_depicted_event.first ? has_depicted_event.first.date_time : []
  end

  def date_portrayed= date_val
    depicted_event = has_depicted_event.first_or_create
    depicted_event.date_time = date_val
  end

  def source
    has_source.first ? has_source.first.description : []
  end

  def source= val
    src = has_source.first_or_create
    src.description = val
  end

  def source_reference
    has_source.first ? has_source.first.identifier : []
  end

  def source_reference= val
    src = has_source.first_or_create
    src.identifier = val
  end

  def rights_holder
    return [] if is_covered_by.empty?
    is_covered_by.first.has_rights_holder.first.name
    # rights.has_rights_holder.present? ? right.has_rights_holder.first
  end

  def rights_holder= val
    r = is_covered_by.first_or_create
    holder = r.has_rights_holder.first_or_create
    holder.name = val
  end

  def release_date
    return [] if related_publication_event.empty?
    related_publication_event.first.start_date_time
  end

  def release_date= val
    evt = related_publication_event.first_or_create
    evt.start_date_time = val
  end

  def aspect_ratio
    track = video_tracks.first
    return [] if track.nil?
    format = track.format.first
    return [] if format.nil?
    format.aspect_ratio
  end

  def aspect_ratio= val
    track = video_tracks.first_or_create
    format = track.format.first_or_create
    format.aspect_ratio = val
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
