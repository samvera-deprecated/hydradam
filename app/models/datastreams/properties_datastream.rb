class PropertiesDatastream < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path=>"fields" ) 
    # This is where we put the user id of the object depositor -- impacts permissions/access controls
    t.depositor :index_as=>[:stored_searchable]
    # This is where we put the relative path of the file if submitted as a folder
    t.relative_path

    # unarranged is true when this is just a pointer at a file on a disk,
    # once descriptive metadata has been added, then mark it false.
    t.unarranged type: :boolean, index_as: :stored_searchable
  end

  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.fields
    end
    builder.doc
  end
end
