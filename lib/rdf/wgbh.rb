module RDF
  # Some custom terms defined by WGBH
  class WGBH < Vocabulary('http://wgbh.org/terms/')
    property :hasReviewDate
    property :hasPhysicalLocation
    property :identifierType
    property :originatingDepartment
  end
end
