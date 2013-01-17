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
      now = DateTime.now
      subject.date_modified = now
      subject.date_uploaded = now
      subject.creator = 'Justin'
      subject.part_of = "Arabiana"
      subject.contributor = "Mohammad"
      subject.title = "Foobar!"
      subject.description = "The work by Allah"
      subject.publisher = "Vertigo Comics"
      subject.date_created = "1200-01-01"
      subject.subject = "Theology"
      subject.language = "Arabic"
      subject.rights = "Wide open, buddy."
      subject.resource_type = "Book"
      subject.identifier = "urn:isbn:1234567890"
      subject.based_near = "Medina, Saudi Arabia"
      subject.related_url = "http://example.org/TheWork/"
      subject.mime_type = "image/jpeg"
      subject.format_label = "JPEG Image"
      
      today_str = "#{Date.today.to_s}T00:00:00Z"
      solr_doc = subject.to_solr
      solr_doc['desc_metadata__title_t'].should == ["Foobar!"]
      solr_doc['desc_metadata__date_modified_dt'].should == [today_str]
      solr_doc['desc_metadata__date_uploaded_dt'].should == [today_str]
      solr_doc['desc_metadata__creator_facet'].should == ['Justin']
      solr_doc['desc_metadata__creator_t'].should == ['Justin']
      solr_doc["desc_metadata__part_of_t"].should be_nil
      solr_doc["desc_metadata__date_uploaded_t"].should be_nil
      solr_doc["desc_metadata__date_modified_t"].should be_nil
      solr_doc["desc_metadata__rights_t"].should == ["Wide open, buddy."]
      solr_doc["desc_metadata__related_url_t"].should be_nil
      solr_doc["desc_metadata__contributor_t"].should == ["Mohammad"]
      solr_doc["desc_metadata__description_t"].should == ["The work by Allah"]
      solr_doc["desc_metadata__publisher_t"].should == ["Vertigo Comics"]
      solr_doc["desc_metadata__subject_t"].should == ["Theology"]
      solr_doc["desc_metadata__language_t"].should == ["Arabic"]
      solr_doc["desc_metadata__date_created_t"].should == ["1200-01-01"]
      solr_doc["desc_metadata__resource_type_t"].should == ["Book"]
      solr_doc["file_format_t"].should == "jpeg (JPEG Image)"
      solr_doc["desc_metadata__identifier_t"].should == ["urn:isbn:1234567890"]
      solr_doc["desc_metadata__based_near_t"].should == ["Medina, Saudi Arabia"]
      solr_doc["mime_type_t"].should == ["image/jpeg"]    
      solr_doc["noid_s"].should == "__DO_NOT_USE__"
      
    end

  end


end
