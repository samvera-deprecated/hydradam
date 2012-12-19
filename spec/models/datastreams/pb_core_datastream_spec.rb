require 'spec_helper'

describe PBCoreDatastream do
  it "should have a list of pbcoreCreators" do
    subject.pbcoreCreator.should == []
  end
end
