module RDF
  ##
  # Public Broadcasting (PBCore) vocabulary.
  #
  # @see http://xmlns.com/foaf/spec/
  class PBCore < Vocabulary("http://www.pbcore.org/PBCore/PBCoreNamespace.html#")
    property :pbcoreDescriptionDocument
    property :pbcoreCreator
    property :creator
    property :creatorRole
    property :titleType
  end
end
