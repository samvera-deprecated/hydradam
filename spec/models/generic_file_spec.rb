require 'spec_helper'

describe GenericFile do
  describe "characterize" do
    before do
      subject.apply_depositor_metadata('frank')
      subject.add_file(File.open(fixture_path + '/sample.mov', 'rb'), 'content', 'sample.mov')
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
      subject.contributor.first.should be_kind_of MediaAnnotationDatastream::Person
      subject.contributor.first.name.first.should == "Sally"
    end
    it "should remove contributors" do
      subject.contributor = ["Sally", "Mary"]
      subject.contributor = ["Bob"]
      subject.contributor.size.should == 1
      subject.contributor.first.name.should == ["Bob"]
    end
  end

  describe "creator attribute" do
    it "should delegate to the bnode" do
      subject.creator = ["Sally", "Mary"]
      subject.descMetadata.creator.first.name.should == ["Sally"]
      subject.descMetadata.creator.last.name.should == ["Mary"]
      subject.creator.first.should be_kind_of MediaAnnotationDatastream::Person
      subject.creator.first.name.first.should == "Sally"
    end

    it "should remove creators" do
      subject.creator = ["Sally", "Mary"]
      subject.creator = ["Bob"]
      subject.creator.size.should == 1
      subject.creator.first.name.should == ["Bob"]
    end
  end

  describe "to_solr" do
    before do
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
      location = subject.based_near.build
      location.location_name = "Medina, Saudi Arabia"
      subject.related_url = "http://example.org/TheWork/"
      subject.mime_type = "image/jpeg"
      subject.format_label = "JPEG Image"
    end
      
    it "should have some fields" do
      today_str = "#{Date.today.to_s}T00:00:00Z"
      solr_doc = subject.to_solr
      solr_doc[Solrizer.solr_name('desc_metadata__title')].should == ["Foobar!"]
      solr_doc[Solrizer.solr_name('desc_metadata__date_modified', type: :date)].should == [today_str]
      solr_doc[Solrizer.solr_name('desc_metadata__date_uploaded', type: :date)].should == [today_str]
      solr_doc[Solrizer.solr_name('desc_metadata__creator', :facetable)].should == ['Justin']
      solr_doc[Solrizer.solr_name('desc_metadata__creator')].should == ['Justin']
      solr_doc[Solrizer.solr_name('desc_metadata__part_of')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__date_uploaded')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__date_modified')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__rights')].should == ["Wide open, buddy."]
      solr_doc[Solrizer.solr_name('desc_metadata__related_url')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__contributor')].should == ["Mohammad"]
      solr_doc[Solrizer.solr_name('desc_metadata__description')].should == ["The work by Allah"]
      solr_doc[Solrizer.solr_name('desc_metadata__publisher')].should == ["Vertigo Comics"]
      solr_doc[Solrizer.solr_name('desc_metadata__subject')].should == ["Theology"]
      solr_doc[Solrizer.solr_name('desc_metadata__language')].should == ["Arabic"]
      solr_doc[Solrizer.solr_name('desc_metadata__date_created')].should == ["1200-01-01"]
      solr_doc[Solrizer.solr_name('desc_metadata__resource_type')].should == ["Book"]
      solr_doc[Solrizer.solr_name('file_format')].should == "jpeg (JPEG Image)"
      solr_doc[Solrizer.solr_name('desc_metadata__identifier')].should == ["urn:isbn:1234567890"]
      solr_doc[Solrizer.solr_name('desc_metadata__based_near')].should == ["Medina, Saudi Arabia"]
      solr_doc[Solrizer.solr_name('mime_type')].should == ["image/jpeg"]    
      #solr_doc[Solrizer.solr_name('noid', :symbol)].should == "__DO_NOT_USE__"
      solr_doc["noid_tsi"].should == "__DO_NOT_USE__"
    end
  end


  describe "#depositor" do
    it "should be there" do
      subject.apply_depositor_metadata('frank')
      subject.depositor.should == 'frank'
    end
  end


  describe "#add_external_file" do
    before do
      subject.apply_depositor_metadata('frank')
      subject.stub(:characterize_if_changed).and_yield #don't run characterization
      FileUtils.copy(File.join(fixture_path + '/sample.mov'), File.join(fixture_path + '/my sample.mov'))
      subject.add_external_file(fixture_path + '/my sample.mov', 'content', 'my sample.mov')
    end

    it "should handle files with spaces in them" do
      # store the URI with spaces escaped to %20
      subject.content.dsLocation.should match /^file:\/\/.*\/__\/DO\/_N\/OT\/_U\/SE\/__\/my%20sample.mov$/
      # But filename should unescape
      subject.content.filename.should match /^\/.*\/__\/DO\/_N\/OT\/_U\/SE\/__\/my sample.mov$/
    end

    it "should set the label" do
      subject.label.should == 'my sample.mov'

    end
  end

  describe "#to_pbcore_xml" do
    before do
      subject.title = ["title one", "second title"]
      c = subject.descMetadata.contributor.build
      c.name = "Fred"
      c.role = "Carpenter"
      c = subject.descMetadata.creator.build
      c.name = "Sally"
      c.role = "Author"

      c = subject.descMetadata.publisher.build
      c.name = "Kelly"
      c.role = "Distributor"

      location = subject.descMetadata.has_location.build
      location.location_name = "France"

      subject.date_created = ["Sept 2009"]
      subject.resource_type = ['Scene']



      subject.ffprobe.content = '<ffprobe>
  <streams>
    <stream avg_frame_rate="2997/100" bit_rate="7664514" codec_long_name="H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10" codec_name="h264" codec_tag="0x31637661" codec_tag_string="avc1" codec_time_base="1/5994" codec_type="video" display_aspect_ratio="0:1" duration="16.016016" duration_ts="48000" has_b_frames="0" height="1080" index="0" is_avc="1" level="41" nal_length_size="4" nb_frames="480" pix_fmt="yuv420p" profile="Main" r_frame_rate="2997/100" sample_aspect_ratio="0:1" start_pts="0" start_time="0.000000" time_base="1/2997" width="1920">
      <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
      <tag key="creation_time" value="2013-01-28 16:53:25"></tag>
      <tag key="language" value="eng"></tag>
      <tag key="handler_name" value="Apple Alias Data Handler"></tag>
    </stream>
    <stream avg_frame_rate="0/0" bit_rate="26935" bits_per_sample="0" channels="2" codec_long_name="AAC (Advanced Audio Coding)" codec_name="aac" codec_tag="0x6134706d" codec_tag_string="mp4a" codec_time_base="1/44100" codec_type="audio" duration="16.021769" duration_ts="706560" index="1" nb_frames="690" r_frame_rate="0/0" sample_fmt="fltp" sample_rate="44100" start_pts="0" start_time="0.000000" time_base="1/44100">
      <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
      <tag key="creation_time" value="2013-01-28 16:53:25"></tag>
      <tag key="language" value="eng"></tag>
      <tag key="handler_name" value="Apple Alias Data Handler"></tag>
    </stream>
  </streams>
</ffprobe>'
    end
    it "should have a title" do
      str = subject.to_pbcore_xml
      puts str
      xml = Nokogiri::XML(str)
      # pbcoretitle
      xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Main"]').text.should == "title one"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Alternative"]').text.should == "second title"
      # pbcorecreator
      #   creator
      #   creatorrole
      xml.xpath('/pbcoreDescriptionDocument/pbcoreCreator[creatorRole="Author"]/creator').text.should == "Sally"
      # pbcorecontributor
      #   contributor
      #   TODO contributorrole Source is MARC?
      xml.xpath('/pbcoreDescriptionDocument/pbcoreContributor[contributorRole="Carpenter"]/contributor').text.should == "Fred"
      # pbcorepublisher
      #   publisher
      #   publisherrole
      xml.xpath('/pbcoreDescriptionDocument/pbcorePublisher[publisherRole="Distributor"]/publisher').text.should == "Kelly"

      # pbcoreCoverage
      #   coverage
      #   coveragetype
      xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Spatial"]/coverage').text.should == "France"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Temporal"]/coverage').text.should == "Sept 2009"
      
      # pbcoreAssetType
      xml.xpath('/pbcoreDescriptionDocument/pbcoreAssetType').text.should == "Scene"

      # pbcoreassetdate TODO
      # pbcoreidentifier TODO
      # pbcoresubject TODO
      # pbcoredescription TODO
      # pbcoregenre TODO
      # pbcorerelation TODO
      # pbcorerelationtype TODO
      # pbcorerelationidentifier TODO
      # pbcoreaudiencelevel TODO
      # pbcoreaudiencerating TODO
      # pbcoreannotation TODO
      # pbcorerightssummary TODO
      #   rightssummary
      #   rightslink
      #   rightsembedded

      # pbcoreInstantiation
      # instantiationIdentifier
      # instantiationDate
      # instantiationDimensions
      # instantiationPhysical
      # instantiationDigital
      # instantiationStandard
      # instantiationLocation
      # instantiationMediaType
      # instantiationGenerations
      # instantiationFileSize
      # instantiationTimeStart
      # instantiationDuration
      # instantiationDataRate
      # instantiationColors
      # instantiationTracks
      # instantiationChannelConfiguration
      # instantiationLanguage
      # instantiationAlternativeModes
      # instantiationEssenceTrack

      # essenceTrackType
      # essenceTrackIdentifier
      # essenceTrackStandard
      # essenceTrackEncoding
      # essenceTrackDataRate
      # essenceTrackFrameRate
      # essenceTrackPlaybackSpeed
      # essenceTrackSamplingRate
      # essenceTrackBitDepth
      # essenceTrackFrameSize
      # essenceTrackAspectRatio
      # essenceTrackTimeStart
      # essenceTrackDuration
      # essenceTrackLanguage
      # essenceTrackAnnotation
      # essenceTrackExtension
      # instantiationRelation
      # instantiationRelationType
      # instantiationRelationIdentifier
      # instantiationRights
      # rightsSummary
      # rightsLink
      # rightsEmbedded
      # instantiationAnnotation
      # instantiationPart
      # instantiationExtension

    end
  end


end
