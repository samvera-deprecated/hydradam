class MediaAnnotationDatastream < RDF::EbuCore::Datastream

  # There seems to be a bug in Active Fedora when you specify nested
  # attributes, e.g. `has_nested_attributes_for :title`,  in your RDF
  # datastream, and then try to delegate your model attributes to the RDF
  # datastream,
  # e.g. `has_attributes :title_attributes, datastream: 'descMetadata'`
  # ActiveFedora expect there to be reader methods, e.g. `#title_attributes`
  # on the datastream, but `has_nested_attributes_for :title` will only
  # create a writer method, e.g. `#title_attributes=`.
  
  # So here we monkey patch the MediaAnnotationDatastream class to provide
  # those reader methods in order to prevent errors from being raised.
  # This is not a good long term fix, but we may no need one, as we are
  # only trying to get this to work as an intermediate step to move on
  # to the next verison of Sufia.

  def creator_attributes; end
  def contributor_attributes; end
  def publisher_attributes; end
  def has_event_attributes; end
  def has_location_attributes; end
  def title_attributes; end
  def description_attributes; end
  def identifier_attributes; end
end