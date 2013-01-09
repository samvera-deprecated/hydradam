require 'spec_helper'

describe GenericFile do
  describe "characterize" do
    before do
      subject.add_file_datastream(File.open(fixture_path + '/sample.mov', 'rb'), :dsid=>'content')
    end
    it "should get fits and ffprobe metadata" do
      subject.characterize
      subject.characterization.mime_type.should == ["video/quicktime", "video/mp4"]
      subject.ffprobe.streams.stream(1).duration == "8.033"
      subject.should be_video
      
    end
  end
end
