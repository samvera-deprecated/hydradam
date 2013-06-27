require 'spec_helper'

describe WGBH::MetadataImporter do
  before { ImportedMetadata.delete_all }
  let(:filename) { fixture_path + '/import/metadata/broadway_or_bust.pbcore.xml' }
  subject { WGBH::MetadataImporter.new(filename) }

  it "should create a template for each entry" do
    expect { subject.import.should == 65 }.to change { ImportedMetadata.count }.by(65)
    ImportedMetadata.first.descMetadata.description_document.series_title.should == ["Broadway or Bust"]
  end
end
