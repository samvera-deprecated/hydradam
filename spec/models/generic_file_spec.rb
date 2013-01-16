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

  describe "terms_for_editing" do
    it "should return a list" do
      subject.terms_for_editing.should == [ :contributor, :creator, :title, :description, :publisher,
       :date_created, :subject, :language, :rights, :identifier, :based_near, :tag, :related_url]
    end
  end
  describe "terms_for_display" do
    it "should return a list" do
      subject.terms_for_display.should == [ :part_of, :contributor, :creator, :title, :description, 
        :publisher, :date_created, :date_uploaded, :date_modified,:subject, :language, :rights, 
        :resource_type, :identifier, :based_near, :tag, :related_url]
    end
  end


end
