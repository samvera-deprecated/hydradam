module RDF
  ##
  # European Broadcasting Union (EBUCore) vocabulary.
  # @see http://tech.ebu.ch/lang/en/MetadataEbuCore 
  module EbuCore
    extend ActiveSupport::Autoload

    autoload :Datastream

    class Vocabulary < ::RDF::StrictVocabulary("http://www.ebu.ch/metadata/ontologies/ebucore#")
      property :isPartOf
      property :isChapterOf
      property :isFragmentOf
      property :hasPart

      property :hasAudioFormat
      property :hasVideoFormat
      property :hasRole
      property :name
      property :createdIn
      property :hasRightsContact
      property :hasRightsHolder
      property :isCoveredBy
      property :rightsExpression
      property :duration
      property :summary
      property :hasSubject
      property :alternativeTitle

      property :hasPublicationEvent
      property :hasOriginalLanguage
      property :hasContributor
      property :description

      property :topic
      property :hasKeyword
      property :hasObjectType
      property :hasCreator
      property :locator
      property :hasCoverage
      property :eventName
      property :eventDefinition
      property :hasLocation
      property :locationName
      property :hasAnnotation
      property :textualAnnotation
      property :identifier
      property :hasVideoTrack
      property :hasThumbnail
      property :hasPublisher
      property :originalTitle
      property :hasFormat
      property :dateTime
      property :dateCreated
      property :dateIssued
      property :dateDigitized
      property :dateModified
      property :hasGenre
      property :hasAudioTrack
      property :hasLanguage
      property :languageName
      property :hasCaptioning
      property :title
      property :filename
      property :fileByteSize
      property :aspectRatio
      property :frameRate
      property :isRelatedTo
      property :references
      property :hasMember
      property :hasRelatedImage
      property :hasRelatedResource
      property :hasSource
      property :hasVersion
      property :isImageRelatedTo
      property :isMemberOf
      property :isReferencedBy
      property :isReplacedBy
      property :isRequiredBy
      property :isSourceOf
      property :isVersionOf
      property :references
      property :relatedEditorialObject
      property :relatedPublicationEvent
      property :relatedResource
      property :replaces
      property :requires
      property :publishedStartDateTime
      property :publishedEndDateTime
      property :publicationEventName

      property :Resource
      property :MediaResource
      property :VideoTrack
      property :VideoFormat
      property :Annotation
      property :Agent
      property :Person
      property :Location
      property :Language
      property :Captioning
      property :Track
      property :Event
      property :DepictedEvent
      property :PublicationEvent
      property :Rights
    end
  end
end

