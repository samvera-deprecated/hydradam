require 'spec_helper'

describe MediaAnnotationDatastream do
  let (:ds) do
    mock_obj = stub(:mock_obj, :pid=>'test:124', :new? => true)
    ds = MediaAnnotationDatastream.new(mock_obj)
  end

  it "should have a default format" do
    ds.format.should == ['Video']
  end

  it "should have many contributors" do
    p = MediaAnnotationDatastream::Person.new
    p.name = 'Baker, R. Lisle'
    p.role = 'Director'
    ds.contributors = [p]
    ds.contributors.first.name.should == ['Baker, R. Lisle']
  end

  it "should have date_uploaded" do
    ds.date_uploaded = Date.new
  end
  it "should have date_modified" do
    ds.date_modified = Date.new
  end
end
