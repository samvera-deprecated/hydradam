module RDF
  module EbuCore
    class Datastream < ActiveFedora::NtriplesRDFDatastream

      property :is_part_of, predicate: RDF::EbuCore::Vocabulary.isPartOf

      # map_predicates do |map|
      #   map.part_of(to: "isPartOf", in: RDF::EbuCore)
      
      #   map.contributor(in: RDF::EbuCore, to:'hasContributor', class_name: 'Person')
      #   map.creator(in: RDF::EbuCore, to:'hasCreator', class_name: 'Person')
      #   map.publisher(in: RDF::EbuCore, to:'hasPublisher', class_name: 'Person')
      #   map.video_tracks(in: RDF::EbuCore, to:'hasVideoTrack', class_name: 'VideoTrack')
      #   map.captioning(in: RDF::EbuCore, to:'hasCaptioning', class_name: 'Captioning')
      #   map.description(in: RDF::EbuCore)

      #   map.has_event(:in => RDF::EbuCore, :to=>'hasCoverage', :class_name=>'Event')
      #   map.has_depicted_event(:in => RDF::EbuCore, :to=>'hasCoverage', :class_name=>'DepictedEvent')

      #   map.is_covered_by(in: RDF::EbuCore, to: 'isCoveredBy', class_name: 'Rights')


      #   map.date_modified(:to => "dateModified", in: RDF::EbuCore) do |index|
      #     index.type :date
      #     index.as :stored_sortable
      #   end
      #   map.date_created(in: RDF::EbuCore, :to => 'dateCreated') do |index|
      #     index.as :stored_searchable
      #   end

      #   map.filename(in: RDF::EbuCore)
      #   map.fileByteSize(in: RDF::EbuCore)


      #   map.subject(in: RDF::EbuCore, :to=>'hasSubject') do |index|
      #     index.as :stored_searchable
      #   end
      #   map.keyword(in: RDF::EbuCore, :to=>'hasKeyword') do |index|
      #     index.as :stored_searchable
      #   end
      #   map.summary(in: RDF::EbuCore) do |index|
      #     index.as :stored_searchable
      #   end
      #   map.duration(in: RDF::EbuCore) do |index|
      #     index.as :stored_searchable
      #   end

      #   map.rights(in: RDF::EbuCore, to: 'rightsExpression') do |index|
      #     index.as :stored_searchable
      #   end
      #   map.resource_type(to: "hasObjectType", in: RDF::EbuCore) do |index|
      #     index.as :stored_searchable, :facetable
      #   end

      #   map.has_source(to: "hasSource", in: RDF::EbuCore, class_name: 'Resource')

      #   map.related_publication_event(to: "relatedPublicationEvent", in: RDF::EbuCore, class_name: 'PublicationEvent')

      #   map.annotations(to: "hasAnnotation", in: RDF::EbuCore, class_name: 'Annotation')

      #   map.identifier(in: RDF::EbuCore) do |index|
      #     index.as :stored_searchable
      #   end

      #   map.language(in: RDF::EbuCore, :to=>'hasLanguage') do |index|
      #     index.as :stored_searchable, :facetable
      #   end


      #   map.tag(to: "isRelatedTo", in: RDF::EbuCore) do |index|
      #     index.as :stored_searchable, :facetable
      #   end

      # end

      accepts_nested_attributes_for :creator, :contributor, :publisher, :has_location, :has_event

      class Person
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Person
        # map_predicates do |map|
        #   map.name(in: RDF::EbuCore) do |index|
        #     index.as :stored_searchable
        #   end
        #   map.role(in: RDF::EbuCore, to: 'hasRole') 
        # end
      end

      class Agent
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Agent
        # map_predicates do |map|
        #   map.name(in: RDF::EbuCore) do |index|
        #     index.as :stored_searchable
        #   end
        # end
      end

      class Location
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Location
        # map_predicates do |map|
        #   map.location_name(in: RDF::EbuCore, to: 'locationName') do |index|
        #     index.as :stored_searchable, :facetable
        #   end
        # end
      end

      class Event
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Event
        # map_predicates do |map|
        #   map.event_name(in: RDF::EbuCore, to: 'eventName')
        #   map.event_definition(in: RDF::EbuCore, to: 'eventDefinition')
        #   map.date_time(in: RDF::EbuCore, to: 'dateTime')
        #   map.has_location(in: RDF::EbuCore, to: 'hasLocation', class_name: "Location")
        # end
        # accepts_nested_attributes_for :has_location
      end

      class Rights
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Rights
        # map_predicates do |map|
        #   map.rights_expression(in: RDF::EbuCore, to: 'rightsExpression')
        #   map.has_rights_holder(in: RDF::EbuCore, to: 'hasRightsHolder', class_name: "Agent")
        # end
      end

      class DepictedEvent
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.DepictedEvent
        # map_predicates do |map|
        #   map.date_time(in: RDF::EbuCore, to: 'dateTime')
        # end
      end

      class PublicationEvent
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.PublicationEvent
        # map_predicates do |map|
        #   map.start_date_time(in: RDF::EbuCore, to: 'publishedStartDateTime')
        #   map.end_date_time(in: RDF::EbuCore, to: 'publishedEndDateTime')
        #   map.name(in: RDF::EbuCore, to: 'publicationEventName')
        # end
      end

      class Resource
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Resource
        # map_predicates do |map|
        #   map.description(:in => RDF::EbuCore)
        #   map.identifier(:in => RDF::EbuCore)
        # end
      end

      class Language
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Language
        # map_predicates do |map|
        #   map.name(in: RDF::EbuCore, to: 'languageName')
        # end
      end
      
      class Track
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Track
        # map_predicates do |map|
        #   map.language(in: RDF::EbuCore, to: 'hasLanguage', class_name: 'Language')
        # end
      end

      class VideoTrack < Track
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.VideoTrack
        # map_predicates do |map|
        #   map.frame_rate(in: RDF::EbuCore, to: 'frameRate') #type is double
        #   map.format(in: RDF::EbuCore, to: 'hasFormat', class_name: 'VideoFormat')
        # end
      end

      class Captioning < Track
        # rdf_type RDF::EbuCore.Captioning
      end

      class VideoFormat
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.VideoFormat
        # map_predicates do |map|
        #   map.aspect_ratio(in: RDF::EbuCore, to: 'aspectRatio')
        # end
      end

      class Annotation
        # include ActiveFedora::RdfObject
        # rdf_type RDF::EbuCore.Annotation
        # map_predicates do |map|
        #   map.textual_annotation(in: RDF::EbuCore, to: 'textualAnnotation')
        # end
      end
    end
  end
end
