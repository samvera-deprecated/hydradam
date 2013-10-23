require 'spec_helper'

describe ExportPbcoreDatastream do
  it "should have title with a type argument" do
    subject.title('Program', "Sample Program")
    subject.title('Series', "Sample Series")
    subject.title('Item', "Sample Item")
    subject.title('Episode', "Sample Episode")

    xml = subject.ng_xml
    xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Program"]').text.should == "Sample Program"
    xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Series"]').text.should == "Sample Series"
    xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Item"]').text.should == "Sample Item"
    xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Episode"]').text.should == "Sample Episode"
  end
end
