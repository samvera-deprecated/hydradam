class MediaAnnotationDatastream < RDF::EbuCore::Datastream
  map_predicates do |map|
    map.title(:in=> RDF::DC, :class_name=>'Title')

    map.date_uploaded(:to => "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end
    map.related_url(:to => "seeAlso", in: RDF::RDFS)

    map.description(in: RDF::EbuCore, class_name: 'Description')
    map.review_date(in: RDF::WGBH, to: 'hasReviewDate')
    map.physical_location(in: RDF::WGBH, to: 'hasPhysicalLocation')
    map.identifier(in: RDF::EbuCore, class_name: 'Identifier')
    map.originating_department(in: RDF::WGBH, to: 'originatingDepartment')
  end

  accepts_nested_attributes_for :title, :description, :identifier

  class Title
    include ActiveFedora::RdfObject
    map_predicates do |map|
      map.value(in: RDF, to: 'value') do |index|
        index.as :stored_searchable
      end
      map.title_type(in: RDF::PBCore, to: 'titleType') 
    end

    def inspect
      "#<Title @value=\"#{value}\">"
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

  class Identifier
    include ActiveFedora::RdfObject
    map_predicates do |map|
      map.value(in: RDF, to: 'value')
      map.identifier_type(in: RDF::WGBH, to: 'identifierType') 
    end
  end
  

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

  def rights_summary
    return [] if is_covered_by.empty?
    is_covered_by.first.rights_expression
  end

  def rights_summary= val
    r = is_covered_by.first_or_create
    r.rights_expression = val
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

  def frame_rate
    track = video_tracks.first
    return [] if track.nil?
    track.frame_rate
  end

  def frame_rate= val
    track = video_tracks.first_or_create
    track.frame_rate = val
  end

  def cc
    track = captioning.first
    return [] if track.nil?
    language = track.language.first
    return [] if language.nil?
    language.name
  end

  def cc= val
    track = captioning.first_or_create
    language = track.language.first_or_create
    language.name = val
  end

  def nola_code
    find_identifier('NOLA_CODE')
  end

  def tape_id
    find_identifier('ITEM_IDENTIFIER')
  end

  def barcode
    find_identifier('PO_REFERENCE')
  end

  def notes= val
    annotation = annotations.first_or_create
    annotation.textual_annotation = val
  end

  def notes
    annotation = annotations.first
    return [] if annotation.nil?
    annotation.textual_annotation
  end

  def to_solr(solr_doc = {})
    solr_doc = super
    creators = self.creator.map { |c| c.name }.flatten
    Solrizer.insert_field(solr_doc, prefix("creator"), creators, :stored_searchable, :facetable)

    contributors = self.contributor.map { |c| c.name }.flatten
    Solrizer.insert_field(solr_doc, prefix("contributor"), contributors, :stored_searchable, :facetable)

    publishers = self.publisher.map { |c| c.name }.flatten
    Solrizer.insert_field(solr_doc, prefix("publisher"), publishers, :stored_searchable, :facetable)

    identifiers = self.identifier.map { |c| c.value }.flatten
    Solrizer.insert_field(solr_doc, prefix("identifier"), identifiers, :stored_searchable, :facetable)

    self.description.each do |t|
      Solrizer.insert_field(solr_doc, prefix("description"), t.value)
    end
    self.title.each do |t|
      if t.title_type.first
        Solrizer.insert_field(solr_doc, prefix("#{t.title_type.first.downcase}_title"), t.value)
      end
    end
    Solrizer.insert_field(solr_doc, prefix("title"), program_title)



    solr_doc
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
    find_with_matching_property(title, type, :title_type)
  end

  def find_identifier(type)
    find_with_matching_property(identifier, type, :identifier_type)
  end

  def find_with_matching_property(collection, type, property_name)
    collection.reduce([]) do |acc, t|
      acc += t.value if t.send(property_name).first == type
      acc
    end
  end
end
