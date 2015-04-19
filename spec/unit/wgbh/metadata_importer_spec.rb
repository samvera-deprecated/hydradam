require 'spec_helper'

describe WGBH::MetadataImporter do
  before { ImportedMetadata.delete_all }
  let(:filename) { fixture_path + '/import/metadata/broadway_or_bust.pbcore.xml' }
  subject { WGBH::MetadataImporter.new(filename, 'jane') }

  it "should create a template for each entry" do
    expect { subject.import }.to change { ImportedMetadata.count }.by(65)
    expect(subject.import).to eq 65
    expect(ImportedMetadata.first.descMetadata.description_document.series_title).to eq ["Broadway or Bust"]
  end
end
