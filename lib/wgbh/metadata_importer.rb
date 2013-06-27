module WGBH
  class MetadataImporter

    attr_accessor :filename, :user_key

    # @param [String] filename the path for the file to be imported
    # @param [String] user_key the user_id to use as the depositor for the file 
    def initialize(filename, user_key)
      self.filename = filename
      self.user_key = user_key
    end

    def import
      datastream = ImportPbcoreDatastream.from_xml(File.open(filename))
      size = datastream.description_document.count
      0.upto(size - 1) do |n|
        import = ImportedMetadata.new
        import.apply_depositor_metadata(user_key)
        import.descMetadata.content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
        <pbcoreCollection xmlns=\"http://www.pbcore.org/PBCore/PBCoreNamespace.html\">" + datastream.description_document(n).nodeset.to_s + "</pbcoreCollection>"
        import.save!
      end
      size
    end
  end
end
