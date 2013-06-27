require 'spec_helper'

describe ImportedMetadata do
  subject {ImportedMetadata.new}

  after do
    subject.destroy unless subject.new_record?
  end

  it "should respond to noid" do
    subject.save
    subject.noid.should_not be_empty
  end

  it "should apply_depositor_metadata" do
    subject.apply_depositor_metadata("frank")
    subject.edit_users.should == ['frank']
    subject.depositor.should == 'frank'
    subject.save!
  end
end
