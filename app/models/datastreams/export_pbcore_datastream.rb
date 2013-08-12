class ExportPbcoreDatastream < HydraPbcore::Datastream::Document
  def title(type, value)
    ng_xml_will_change!
    ng_xml.root.add_child("<pbcoreTitle titleType=\"#{Array(type).first}\">#{Array(value).first}</pbcoreTitle>")
  end

  define_template :event_place do |xml, location, type="Event Place"|
    xml.pbcoreCoverage {
      xml.coverage(location, :annotation=>type)
      xml.coverageType {
        xml.text "Spatial"
      }
    }
  end

  def insert_place(location, type)
    add_child_node(ng_xml.root, :event_place, location, type)
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
