module WGBH
  class MetadataImporter

    attr_accessor :filename

    def initialize(filename)
      self.filename = filename
    end

    def import
      datastream = ImportPbcoreDatastream.from_xml(File.open(filename))
      size = datastream.description_document.count
      0.upto(size - 1) do |n|
        import = ImportedMetadata.new
        import.descMetadata.content = "<pbcoreCollection xmlns=\"http://www.pbcore.org/PBCore/PBCoreNamespace.html\">" + datastream.description_document(n).nodeset.to_s + "</pbcoreCollection>"
        import.save!
      end
      size
    end
  end
end
