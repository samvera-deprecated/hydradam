require 'spec_helper'

describe MediaAnnotationDatastream do
  let (:ds) do
    mock_obj = double(:mock_obj, :pid=>'test:124', :new? => true)
    ds = MediaAnnotationDatastream.new(mock_obj)
  end

  it "should have many contributors" do
    p = MediaAnnotationDatastream::Person.new(ds.graph)
    p.name = 'Baker, R. Lisle'
    p.role = 'Director'
    ds.contributor = [p]
    expect(ds.contributor.first.name).to eq ['Baker, R. Lisle']
  end

  it "should have date_uploaded" do
    ds.date_uploaded = Date.new
  end
  it "should have date_modified" do
    ds.date_modified = Date.new
  end
end
