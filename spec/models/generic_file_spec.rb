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
  describe "contributor attribute" do
    it "should delegate to the bnode" do
      subject.contributor = ["Sally", "Mary"]
      subject.descMetadata.contributor.first.name.should == ["Sally"]
      subject.descMetadata.contributor.last.name.should == ["Mary"]
      subject.contributor.should == ["Sally", "Mary"]
    end
    it "should remove contributors" do
      subject.contributor = ["Sally", "Mary"]
      subject.contributor = ["Bob"]
      subject.contributor.should == ["Bob"]
    end
  end

  describe "creator attribute" do
    it "should delegate to the bnode" do
      subject.creator = ["Sally", "Mary"]
      subject.descMetadata.creator.first.name.should == ["Sally"]
      subject.descMetadata.creator.last.name.should == ["Mary"]
      subject.creator.should == ["Sally", "Mary"]
    end

    it "should remove creators" do
      subject.creator = ["Sally", "Mary"]
      subject.creator = ["Bob"]
      subject.creator.should == ["Bob"]
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
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__title')].should == ["Foobar!"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__date_modified', type: :date)].should == [today_str]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__date_uploaded', type: :date)].should == [today_str]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__creator', :facetable)].should == ['Justin']
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__creator')].should == ['Justin']
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__part_of')].should be_nil
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__date_uploaded')].should be_nil
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__date_modified')].should be_nil
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__rights')].should == ["Wide open, buddy."]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__related_url')].should be_nil
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__contributor')].should == ["Mohammad"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__description')].should == ["The work by Allah"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__publisher')].should == ["Vertigo Comics"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__subject')].should == ["Theology"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__language')].should == ["Arabic"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__date_created')].should == ["1200-01-01"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__resource_type')].should == ["Book"]
      solr_doc[ActiveFedora::SolrService.solr_name('file_format')].should == "jpeg (JPEG Image)"
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__identifier')].should == ["urn:isbn:1234567890"]
      solr_doc[ActiveFedora::SolrService.solr_name('desc_metadata__based_near')].should == ["Medina, Saudi Arabia"]
      solr_doc[ActiveFedora::SolrService.solr_name('mime_type')].should == ["image/jpeg"]    
      solr_doc[ActiveFedora::SolrService.solr_name('noid', :symbol)].should == "__DO_NOT_USE__"
      
    end

  end


end
