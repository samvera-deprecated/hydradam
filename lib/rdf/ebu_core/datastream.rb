module RDF
  module EbuCore
    class Datastream < ActiveFedora::NtriplesRDFDatastream

      # TODO: Find out what this is used for
      property :is_part_of, predicate: RDF::EbuCore::Vocabulary.isPartOf

      property :date_modified, predicate: RDF::EbuCore::Vocabulary.dateModified, multiple: false do |index|
        index.type :date
        index.as :stored_searchable
      end

      property :date_created, predicate: RDF::EbuCore::Vocabulary.dateCreated, multiple: false do |index|
        index.type :date
        index.as :stored_searchable
      end

      property :contributors, predicate: RDF::EbuCore::Vocabulary.hasContributor, class_name: 'Person'
      property :creators, predicate: RDF::EbuCore::Vocabulary.hasCreator, class_name: 'Person'
      property :publishers, predicate: RDF::EbuCore::Vocabulary.hasPublisher, class_name: 'Person'
      property :video_tracks, predicate: RDF::EbuCore::Vocabulary.hasVideoTrack, class_name: 'VideoTrack'
      property :captioning, predicate: RDF::EbuCore::Vocabulary.hasCaptioning, class_name: 'Captioning'
      property :description, predicate: RDF::EbuCore::Vocabulary.description

      property :has_event, predicate: RDF::EbuCore::Vocabulary.hasCoverage, class_name: 'Event'
      property :has_depicted_event, predicate: RDF::EbuCore::Vocabulary.hasCoverage, class_name: 'DepictedEvent'

      property :is_covered_by, predicate: RDF::EbuCore::Vocabulary.isCoveredBy, class_name: 'Rights'

      property :filename, predicate: RDF::EbuCore::Vocabulary.filename
      property :fileByteSize, predicate: RDF::EbuCore::Vocabulary.fileByteSize

      property :subject, predicate: RDF::EbuCore::Vocabulary.hasSubject do |index|
        index.as :stored_searchable
      end

      property :keyword, predicate: RDF::EbuCore::Vocabulary.hasKeyword do |index|
        index.as :stored_searchable
      end

      property :summary, predicate: RDF::EbuCore::Vocabulary.summary do |index|
        index.as :stored_searchable
      end

      property :duration, prediate: RDF::EbuCore::Vocabulary.duration do |index|
        index.as :stored_searchable
      end

      property :rights, predicate: RDF::EbuCore::Vocabulary.rightsExpression do |index|
        index.as :stored_searchable
      end
      
      property :resource_type, predicate: RDF::EbuCore::Vocabulary.hasObjectType do |index|
        index.as :stored_searchable, :facetable
      end

      property :has_source, predicate: RDF::EbuCore::Vocabulary.hasSource, class_name: 'Resource'

      property :related_publication_event, predicate: RDF::EbuCore::Vocabulary.relatedPublicationEvent, class_name: 'PublicationEvent'

      property :annotations, predicate: RDF::EbuCore::Vocabulary.hasAnnotation, class_name: 'Annotation'

      property :identifier, predicate: RDF::EbuCore::Vocabulary.predicate do |index|
        index.as :stored_searchable
      end

      property :language, predicate: RDF::EbuCore::Vocabulary.hasLanguage do |index|
        index.as :stored_searchable, :facetable
      end


      property :tag, predicate: RDF::EbuCore::Vocabulary.isRelatedTo do |index|
        index.as :stored_searchable, :facetable
      end


      accepts_nested_attributes_for :creator, :contributor, :publisher, :has_location, :has_event

      class Person < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Person
        property :full_name, predicate: RDF::EbuCore::Vocabulary.name
        property :role, predicate: RDF::EbuCore::Vocabulary.hasRole
      end

      class Agent < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Agent
        property :agent_name, predicate: RDF::EbuCore::Vocabulary.name do |index|
          index.as :stored_searchable
        end
      end

      class Location < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Location
        property :location_name, predicate: RDF::EbuCore::Vocabulary.locationName do |index|
          index.as :stored_searchable, :facetable
        end
      end

      class Event < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Event

        property :event_name, predicate: RDF::EbuCore::Vocabulary.eventName
        property :event_definition, predicate: RDF::EbuCore::Vocabulary.eventDefinition
        property :date_time, predicate: RDF::EbuCore::Vocabulary.dateTime
        property :has_location, predicate: RDF::EbuCore::Vocabulary.hasLocation, class_name: 'Location'

        accepts_nested_attributes_for :has_location
      end

      class Rights < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Rights
        property :rights_expression, predicate: RDF::EbuCore::Vocabulary.rightsExpression
        property :has_rights_holder, predicate: RDF::EbuCore::Vocabulary.hasRightsHolder, class_name: 'Agent'
      end

      class DepictedEvent < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.DepictedEvent
        property :date_time, predicate: RDF::EbuCore::Vocabulary.dateTime
      end

      class PublicationEvent < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.PublicationEvent
        property :start_date_time, predicate: RDF::EbuCore::Vocabulary.publishedStartDateTime
        property :end_date_time, predicate: RDF::EbuCore::Vocabulary.publishedEndDateTime
        property :publication_event_name, predicate: RDF::EbuCore::Vocabulary.publicationEventName
      end

      class Resource < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Resource
        property :description, predicate: RDF::EbuCore::Vocabulary.description
        property :identifier, predicate: RDF::EbuCore::Vocabulary.identifier
      end

      class Language < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Language
        property :language_name, predicate: RDF::EbuCore::Vocabulary.languageName
      end
      
      class Track < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Track
        property :language, predicate: RDF::EbuCore::Vocabulary.hasLanguage, class_name: 'Language'
      end

      class VideoTrack < Track
        property :frame_rate, predicate: RDF::EbuCore::Vocabulary.frameRate #type is double
        property :format, predicate: RDF::EbuCore::Vocabulary.hasFormat, class_name: 'VideoFormat'
      end

      class Captioning < Track
        configure type: RDF::EbuCore::Vocabulary.Captioning
      end

      class VideoFormat < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.VideoFormat
        property :aspect_ratio, predicate: RDF::EbuCore::Vocabulary.aspectRatio
      end

      class Annotation < ActiveTriples::Resource
        configure type: RDF::EbuCore::Vocabulary.Annotation
        property :textual_annotation, predicate: RDF::EbuCore::Vocabulary.textualAnnotation
      end
    end
  end
end
