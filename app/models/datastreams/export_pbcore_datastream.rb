class ExportPbcoreDatastream < HydraPbcore::Datastream::Document
  
  extend_terminology do |t|
    # Needed until hydra-pbcore > 3.0.0 is out
    t.asset_date(path: 'pbcoreAssetDate', index_as: :displayable)
  end


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

  define_template :relation do |xml, value, annotation, type="Is Part Of"|
    xml.pbcoreRelation {
      xml.pbcoreRelationType(type, :annotation=>annotation)
      xml.pbcoreRelationIdentifier(value)
    }
  end

  define_template :rights do |xml, holder, rights|
    xml.rightsEmbedded {
      xml.WGBH_RIGHTS(:RIGHTS_HOLDER=> holder, :RIGHTS=>rights)
    }
  end

  define_template :release do |xml, date|
    xml.pbcoreExtension(:annotation=>"Release date information") {
      xml.WGBH_DATE_RELEASE(:DATE_RELEASE=>date)
    }
  end

  define_template :review do |xml, date|
    xml.pbcoreExtension(:annotation=>"Lifecycle information") {
      xml.WGBH_DATE(:REVIEW_DATE=>date)
    }
  end

  define_template :identifier do |xml, identifier, source, annotation|
    xml.pbcoreIdentifier(identifier, source: source, annotation: annotation)
  end

  def insert_place(location, type)
    add_child_node(ng_xml.root, :event_place, location, type)
  end

  def insert_relation(description, identifier)
    add_child_node(ng_xml.root, :relation, identifier, 'SOURCE', description)
  end

  def insert_rights(holder, summary)
    add_child_node(ng_xml.root, :rights, holder, summary)
  end

  def insert_release_date(date)
    add_child_node(ng_xml.root, :release, date)
  end

  def insert_review_date(date)
    add_child_node(ng_xml.root, :review, date)
  end

  def insert_identifier(identifier, source=HydraPbcore.config["institution"], annotation=nil)
    add_child_node(ng_xml.root, :identifier, identifier, source, annotation)
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
