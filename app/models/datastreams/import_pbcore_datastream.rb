class ImportPbcoreDatastream < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root path: 'pbcoreCollection', 'xmlns'=> "http://www.pbcore.org/PBCore/PBCoreNamespace.html"
    t.description_document path: 'pbcoreDescriptionDocument' do
      t.item_title path: 'pbcoreTitle', attributes: { titleType: "Item"}
      t.episode_title path: 'pbcoreTitle', attributes: { titleType: "Episode"}
      t.program_title path: 'pbcoreTitle', attributes: { titleType: "Program"}
      t.series_title path: 'pbcoreTitle', attributes: { titleType: "Series"}

      t.filenames(path: 'pbcoreRelation[./oxns:pbcoreRelationType/@source="SOURCE_FILENAME"]/oxns:pbcoreRelationIdentifier')
      t.folder(path: 'pbcoreRelation[./oxns:pbcoreRelationType/@source="SOURCE_FOLDERNAME"]/oxns:pbcoreRelationIdentifier')
      t.drive(path: 'pbcoreRelation[./oxns:pbcoreRelationType/@source="SOURCE_DRIVENAME"]/oxns:pbcoreRelationIdentifier')

      t.pbcoreCoverage {
        t.location path: 'coverage', attributes: { source: 'COVERAGE_EVENT_LOCATION'}
      }

      t.description path: 'pbcoreDescription'
    end

    t.series_title proxy: [:description_document, :series_title], index_as: :stored_searchable
    t.program_title proxy: [:description_document, :program_title], index_as: :stored_searchable
    t.episode_title proxy: [:description_document, :episode_title], index_as: :stored_searchable
    t.item_title proxy: [:description_document, :item_title], index_as: :stored_searchable
    t.filenames proxy: [:description_document, :filenames], index_as: :stored_searchable
    t.folder_name proxy: [:description_document, :folder], index_as: :stored_searchable
    t.drive_name proxy: [:description_document, :drive], index_as: :stored_searchable
    t.description proxy: [:description_document, :description], index_as: :stored_searchable
    t.event_location proxy: [:description_document, :pbcoreCoverage, :location], index_as: :stored_searchable

    

  end

  def self.xml_template

    xml = '<?xml version="1.0" encoding="UTF-8"?>
<pbcoreCollection xmlns="http://www.pbcore.org/PBCore/PBCoreNamespace.html">
  <pbcoreDescriptionDocument>
    <pbcoreRelation>
      <pbcoreRelationType source="SOURCE_FILENAME">File Name</pbcoreRelationType>
      <pbcoreRelationIdentifier></pbcoreRelationIdentifier>
    </pbcoreRelation>
    <pbcoreRelation>
      <pbcoreRelationType source="SOURCE_FOLDERNAME">Folder Name</pbcoreRelationType>
      <pbcoreRelationIdentifier></pbcoreRelationIdentifier>
    </pbcoreRelation>
    <pbcoreRelation>
    <pbcoreRelationType source="SOURCE_DRIVENAME">Drive Name</pbcoreRelationType>
    <pbcoreRelationIdentifier></pbcoreRelationIdentifier>
    </pbcoreRelation>
    <pbcoreCoverage>
    <coverage source="COVERAGE_EVENT_LOCATION"></coverage>
    <coverageType>Spatial</coverageType>
    </pbcoreCoverage>
    <pbcoreCoverage>
    <coverage source="COVERAGE_DATE_PORTRAYED"></coverage>
    <coverageType>Temporal</coverageType>
    </pbcoreCoverage>
  </pbcoreDescriptionDocument>
</pbcoreCollection>'
    Nokogiri::XML.parse(xml)
  end

end
