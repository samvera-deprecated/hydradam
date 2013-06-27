require 'spec_helper'

describe ImportedMetadata do
  subject {ImportedMetadata.new}
  it "should respond to noid" do
    subject.save
    subject.noid.should_not be_empty
  end
end