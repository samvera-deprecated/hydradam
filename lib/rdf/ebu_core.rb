module RDF
  ##
  # European Broadcasting Union (EBUCore) vocabulary.
  # @see http://tech.ebu.ch/lang/en/MetadataEbuCore 
  class EbuCore < Vocabulary("http://www.ebu.ch/metadata/ontologies/ebucore#")

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
    property :hasLocation
    property :locationName

    property :identifier
    property :hasVideoTrack
    property :hasThumbnail
    property :hasPublisher
    property :originalTitle
    property :hasFormat

    property :dateCreated
    property :dateIssued
    property :dateDigitized
    property :dateModified
    property :hasGenre

    property :hasAudioTrack
    property :hasLanguage
    property :title
    property :filename
    property :fileByteSize

    property :isRelatedTo
    # The following are subproperties of isRelatedTo
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
  end
end

