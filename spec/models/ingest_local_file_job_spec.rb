require 'spec_helper'

describe IngestLocalFileJob do
  before do
    FileUtils.copy('spec/fixtures/world.png', 'tmp/')
    @generic_file = GenericFile.new
    @generic_file.apply_depositor_metadata('jcoyne@example.com')
    @generic_file.save!
    u = User.new
    u.stub(:user_key).and_return('jcoyne@example.com')
    User.stub(:find_by_user_key).with('jcoyne@example.com').and_return(u)
  end
  subject { IngestLocalFileJob.new @generic_file.id, 'tmp', 'world.png', 'jcoyne@example.com' }
  it "should make an external datastream" do
    subject.run
    @generic_file.reload
    expect(@generic_file.content.controlGroup).to eq 'E'
    expect(@generic_file.content.dsLocation).to match /file:\/\/\/.*\/spec\/storage\/..\/..\/..\/..\/.\/world\.png$/
  end
end
