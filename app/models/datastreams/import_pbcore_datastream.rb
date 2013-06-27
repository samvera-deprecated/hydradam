class ImportPbcoreDatastream < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root path: 'pbcoreCollection', 'xmlns'=> "http://www.pbcore.org/PBCore/PBCoreNamespace.html"
    t.description_document path: 'pbcoreDescriptionDocument' do
      t.item_title path: 'pbcoreTitle', attributes: { titleType: "Item"}
      t.episode_title path: 'pbcoreTitle', attributes: { titleType: "Episode"}
      t.program_title path: 'pbcoreTitle', attributes: { titleType: "Program"}
      t.series_title path: 'pbcoreTitle', attributes: { titleType: "Series"}

      t.filename(path: 'pbcoreRelation[./oxns:pbcoreRelationType/@source="SOURCE_FILENAME"]/oxns:pbcoreRelationIdentifier')
      t.folder(path: 'pbcoreRelation[./oxns:pbcoreRelationType/@source="SOURCE_FOLDERNAME"]/oxns:pbcoreRelationIdentifier')
      t.drive(path: 'pbcoreRelation[./oxns:pbcoreRelationType/@source="SOURCE_DRIVENAME"]/oxns:pbcoreRelationIdentifier')

      t.description path: 'pbcoreDescription'
    end

    t.series_title proxy: [:description_document, :series_title], index_as: :stored_searchable
    t.program_title proxy: [:description_document, :program_title], index_as: :stored_searchable
    t.episode_title proxy: [:description_document, :episode_title], index_as: :stored_searchable
    t.item_title proxy: [:description_document, :item_title], index_as: :stored_searchable
    t.filename proxy: [:description_document, :filename], index_as: :stored_searchable
    t.folder_name proxy: [:description_document, :folder], index_as: :stored_searchable
    t.drive_name proxy: [:description_document, :drive], index_as: :stored_searchable
    t.description proxy: [:description_document, :description], index_as: :stored_searchable

  end

  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcoreCollection(:xmlns => "http://www.pbcore.org/PBCore/PBCoreNamespace.html")
    end

    builder.doc
  end

end
