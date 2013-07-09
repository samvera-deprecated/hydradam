class ExportPbcoreDatastream < HydraPbcore::Datastream::Document
  def self.template_registry
    # This should be inheritable from the superclass.
    # This is a temporary (hopefully) hack to make it work
    HydraPbcore::Datastream::Document.template_registry
  end

  def self.terminology
    # This should be inheritable from the superclass.
    # This is a temporary (hopefully) hack to make it work
    HydraPbcore::Datastream::Document.terminology
  end


  def title(type, value)
    ng_xml_will_change!
    ng_xml.root.add_child("<pbcoreTitle titleType=\"#{Array(type).first}\">#{Array(value).first}</pbcoreTitle>")

  end


  # Just a very minimal template 
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcoreDescriptionDocument("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html") 
    end
    return builder.doc
  end
end
