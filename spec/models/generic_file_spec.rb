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

  describe "to_solr" do
    it "should have some fields" do
      subject.title = "Foobar!"
      now = DateTime.now
      subject.date_modified = now
      subject.date_uploaded = now
      
      today_str = "#{Date.today.to_s}T00:00:00Z"
      solr_doc = subject.to_solr
      solr_doc['desc_metadata__title_t'].should == ["Foobar!"]
      solr_doc['desc_metadata__date_modified_dt'].should == [today_str]
      solr_doc['desc_metadata__date_uploaded_dt'].should == [today_str]
      #solr_doc['label_t'].should == ["Foobar!"]
    end

  end


end
