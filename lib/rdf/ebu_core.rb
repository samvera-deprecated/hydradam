module RDF
  ##
  # European Broadcasting Union (EBUCore) vocabulary.
  # @see http://tech.ebu.ch/lang/en/MetadataEbuCore 
  module EbuCore
    extend ActiveSupport::Autoload

    autoload :Datastream

    class Vocabulary < ::RDF::Vocabulary("http://www.ebu.ch/metadata/ontologies/ebucore#")
      property :is_part_of
    end

    # def self.to_uri
    #   RDF::URI.intern("http://www.ebu.ch/metadata/ontologies/ebucore#")
    # end


    # # Vocabulary terms
    # %w(
    #   isPartOf
    #   isChapterOf
    #   isFragmentOf
    #   hasPart

    #   hasAudioFormat
    #   hasVideoFormat
    #   hasRole
    #   name
    #   createdIn
    #   hasRightsContact
    #   hasRightsHolder
    #   isCoveredBy
    #   rightsExpression
    #   duration
    #   summary
    #   hasSubject
    #   alternativeTitle

    #   hasPublicationEvent
    #   hasOriginalLanguage
    #   hasContributor
    #   description

    #   topic
    #   hasKeyword
    #   hasObjectType
    #   hasCreator
    #   locator
    #   hasCoverage
    #   eventName
    #   eventDefinition
    #   hasLocation
    #   locationName
    #   hasAnnotation
    #   textualAnnotation
    #   identifier
    #   hasVideoTrack
    #   hasThumbnail
    #   hasPublisher
    #   originalTitle
    #   hasFormat
    #   dateTime
    #   dateCreated
    #   dateIssued
    #   dateDigitized
    #   dateModified
    #   hasGenre
    #   hasAudioTrack
    #   hasLanguage
    #   languageName
    #   hasCaptioning
    #   title
    #   filename
    #   fileByteSize
    #   aspectRatio
    #   frameRate
    #   isRelatedTo
    #   references
    #   hasMember
    #   hasRelatedImage
    #   hasRelatedResource
    #   hasSource
    #   hasVersion
    #   isImageRelatedTo
    #   isMemberOf
    #   isReferencedBy
    #   isReplacedBy
    #   isRequiredBy
    #   isSourceOf
    #   isVersionOf
    #   references
    #   relatedEditorialObject
    #   relatedPublicationEvent
    #   relatedResource
    #   replaces
    #   requires
    #   publishedStartDateTime
    #   publishedEndDateTime
    #   publicationEventName

    #   Resource
    #   MediaResource
    #   VideoTrack
    #   VideoFormat
    #   Annotation
    #   Agent
    #   Person
    #   Location
    #   Language
    #   Captioning
    #   Track
    #   Event
    #   DepictedEvent
    #   PublicationEvent
    #   Rights
    # ).each do |term|
    #   define_method(term) {self[term.to_sym]}
    #   module_function term.to_sym
    # end

    ##
    # @return [#to_s] property
    # @return [URI]
    # def self.[](property)
    #   RDF::URI.intern([to_uri.to_s, property.to_s].join)
    # end
  end
end

