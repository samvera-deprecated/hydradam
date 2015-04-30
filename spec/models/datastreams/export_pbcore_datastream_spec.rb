require 'spec_helper'

describe ExportPbcoreDatastream do

  describe '#title' do
    it "should have title with a type argument" do

      subject.title('Program', "Sample Program")
      subject.title('Series', "Sample Series")
      subject.title('Item', "Sample Item")
      subject.title('Episode', "Sample Episode")

      xml = subject.ng_xml
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Program"]').text).to eq "Sample Program"
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Series"]').text).to eq "Sample Series"
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Item"]').text).to eq "Sample Item"
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Episode"]').text).to eq "Sample Episode"
    end
  end
end
