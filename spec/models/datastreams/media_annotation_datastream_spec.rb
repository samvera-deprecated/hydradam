require 'spec_helper'

describe MediaAnnotationDatastream do
  subject { MediaAnnotationDatastream.new }

  it "allows many contributors" do
    p = MediaAnnotationDatastream::Person.new
    p.full_name = 'Baker, R. Lisle'
    p.role = 'Director'
    subject.contributors = [p]
    expect(subject.contributors.first.name).to eq ['Baker, R. Lisle']
  end

  it "should have date_uploaded" do
    subject.date_uploaded = Date.new
  end

  it "should have date_modified" do
    subject.date_modified = Date.new
  end
end
