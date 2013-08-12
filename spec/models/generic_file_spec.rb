require 'spec_helper'

describe GenericFile do
  describe "characterize" do
    before do
      subject.apply_depositor_metadata('frank')
      subject.add_file(File.open(fixture_path + '/sample.mov', 'rb'), 'content', 'sample.mov')
    end
    it "should get fits and ffprobe metadata" do
      subject.characterize
      subject.characterization.mime_type.should == ["video/quicktime", "video/quicktime"]
      subject.ffprobe.streams.stream(1).duration == "8.033"
      subject.should be_video
      
    end
  end

  describe "mxf recognition" do
    before do
      subject.characterization.mime_type = ['application/mxf']
    end
    describe "when the mxf has video tracks" do
      before do
        subject.ffprobe.content =<<EOF
<ffprobe>
  <streams>
    <stream avg_frame_rate="30000/1001" codec_long_name="MPEG-2 video" codec_name="mpeg2video" codec_tag="0x0000" codec_tag_string="[0][0][0][0]" codec_time_base="1001/60000" codec_type="video" display_aspect_ratio="16:9" duration="2.002000" duration_ts="60" has_b_frames="1" height="1080" index="0" level="2" pix_fmt="yuv422p" profile="4:2:2" r_frame_rate="30000/1001" sample_aspect_ratio="1:1" start_pts="0" start_time="0.000000" time_base="1001/30000" timecode="00:00:00:00" width="1920">
      <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
    </stream>
    <stream avg_frame_rate="0/0" bit_rate="1152000" bits_per_sample="24" channels="1" codec_long_name="PCM signed 24-bit little-endian" codec_name="pcm_s24le" codec_tag="0x0000" codec_tag_string="[0][0][0][0]" codec_time_base="1/48000" codec_type="audio" duration="2.002000" duration_ts="96096" index="1" r_frame_rate="0/0" sample_fmt="s32" sample_rate="48000" start_pts="0" start_time="0.000000" time_base="1/48000">
      <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
    </stream>
    </streams>
</ffprobe>
EOF
      end
      its(:video?) { should be_true}
      its(:audio?) { should be_false}
    end

    describe "when the mxf only has audio tracks" do
      before do
        subject.ffprobe.content =<<EOF
<ffprobe>
    <streams>
        <stream index="0" codec_name="pcm_s16le" codec_long_name="PCM signed 16-bit little-endian" codec_type="audio" codec_time_base="1/48000" codec_tag_string="[0][0][0][0]" codec_tag="0x0000" sample_fmt="s16" sample_rate="48000" channels="1" bits_per_sample="16" r_frame_rate="0/0" avg_frame_rate="0/0" time_base="1/48000" start_pts="0" start_time="0.000000" duration_ts="1723320" duration="35.902500" bit_rate="768000">
            <disposition default="0" dub="0" original="0" comment="0" lyrics="0" karaoke="0" forced="0" hearing_impaired="0" visual_impaired="0" clean_effects="0" attached_pic="0"/>
        </stream>
    </streams>
</ffprobe>
EOF
      end
      its(:video?) { should be_false}
      its(:audio?) { should be_true}
    end
  end

  describe "terms_for_editing" do
    it "should return a list" do
      subject.terms_for_editing.should == [ :contributor, :creator, :title, :description, 
        :event_location, :production_location, :date_portrayed, :source, :source_reference,
        :rights_holder, :rights_summary, :publisher, :date_created, :release_date, :review_date,
        :aspect_ratio, :frame_rate, :cc, :physical_location, :identifier, :metadata_filename,
        :notes, :originating_department, :subject, :language, :rights, :resource_type, :tag,
        :related_url]
    end
  end
  describe "terms_for_display" do
    it "should return a list" do
      subject.terms_for_display.should == [ :part_of, :contributor, :creator, :title, :description, 
        :event_location, :production_location, :date_portrayed, :source, :source_reference,
        :rights_holder, :rights_summary, :publisher, :date_created, :release_date, :review_date,
        :aspect_ratio, :frame_rate, :cc, :physical_location, :identifier, :metadata_filename,
        :notes, :originating_department, :date_uploaded, :date_modified, :subject, :language,
        :rights, :resource_type, :tag, :related_url]
    end
  end
  describe "contributor attribute" do
    it "should delegate to the bnode" do
      subject.contributor_attributes = [{name: "Sally"}, {name:"Mary"}]
      subject.descMetadata.contributor.first.name.should == ["Sally"]
      subject.descMetadata.contributor.last.name.should == ["Mary"]
      subject.contributor.first.should be_kind_of MediaAnnotationDatastream::Person
      subject.contributor.first.name.first.should == "Sally"
    end
  end
  describe "publisher attribute" do
    it "should delegate to the bnode" do
      subject.publisher_attributes = [{name: "Sally"}, {name:"Mary"}]
      subject.descMetadata.publisher.first.name.should == ["Sally"]
      subject.descMetadata.publisher.last.name.should == ["Mary"]
      subject.publisher.first.should be_kind_of MediaAnnotationDatastream::Person
      subject.publisher.first.name.first.should == "Sally"
    end
  end

  describe "creator attribute" do
    it "should delegate to the bnode" do
      subject.creator_attributes = [{name: "Sally"}, {name:"Mary"}]
      subject.descMetadata.creator.first.name.should == ["Sally"]
      subject.descMetadata.creator.last.name.should == ["Mary"]
      subject.creator.first.should be_kind_of MediaAnnotationDatastream::Person
      subject.creator.first.name.first.should == "Sally"
    end
  end

  describe "description attribute" do
    it "should delegate to the bnode" do
      subject.description_attributes = [{value: "Order online", type:"Promotional Information"}]
      subject.description.first.value.should == ["Order online"]
      subject.description.first.type.should == ["Promotional Information"]
      subject.description.first.should be_kind_of MediaAnnotationDatastream::Description
    end
  end

  describe "event location" do
    before do
      subject.event_location = ["one", "two"]
    end
    it "should delegate to the bnode" do
      subject.filming_event.has_location[0].location_name.should == ['one']
      subject.filming_event.has_location[1].location_name.should == ['two']
    end
  end
  describe "production location" do
    before do
      subject.production_location = ["one", "two"]
    end
    it "should delegate to the bnode" do
      subject.production_event.has_location[0].location_name.should == ['one']
      subject.production_event.has_location[1].location_name.should == ['two']
    end
  end

  describe "unarranged" do
    after do
      subject.delete
    end
    it "should have it" do
      subject.unarranged.should be_false
      subject.unarranged = true
      subject.save(validate: false)
      subject.reload.unarranged.should be_true
    end
  end

  describe "to_solr" do
    before do
      now = DateTime.now
      subject.date_modified = now
      subject.date_uploaded = now
      subject.creator.build(name: 'Justin')
      subject.part_of = "Arabiana"
      subject.contributor.build(name: "Martin Smith")
      subject.title.build(value: "Frontline", title_type: "Series")
      subject.title.build(value: "The Retirement Gamble", title_type: "Program")
      subject.title.build(value: "12", title_type: "Episode")
      subject.description.build(value: "An examination of retirement accounts. Included: the lack of uniformity in plans, which results in some workers paying much more than others; the cost of a seemingly small annual fee when spread out across a worker's lifetime; hidden fees some 401(k) providers charge consumers.", type: 'summary')
      subject.publisher.build(name: "Vertigo Comics")
      subject.date_created = "1200-01-01"
      subject.subject = "Theology"
      subject.language = "Arabic"
      subject.rights = "Wide open, buddy."
      subject.resource_type = "Book"
      subject.identifier.build(value: "1234567890", identifier_type: 'PO_REFERENCE')
      # location = subject.based_near.build
      # location.location_name = "Medina, Saudi Arabia"
      subject.related_url = "http://example.org/TheWork/"
      subject.mime_type = "image/jpeg"
      subject.format_label = "JPEG Image"
      subject.unarranged = true
      subject.relative_path = 'fortune/smiles/on/the/bold.mkv'
    end
      
    it "should have some fields" do
      today_str = "#{Date.today.to_s}T00:00:00Z"
      solr_doc = subject.to_solr
      solr_doc[Solrizer.solr_name('desc_metadata__series_title')].should == ["Frontline"]
      solr_doc[Solrizer.solr_name('desc_metadata__program_title')].should == ["The Retirement Gamble"]
      solr_doc[Solrizer.solr_name('desc_metadata__episode_title')].should == ["12"]
      solr_doc[Solrizer.solr_name('desc_metadata__date_modified', :stored_sortable, type: :date)].should == today_str
      solr_doc[Solrizer.solr_name('desc_metadata__date_uploaded', :stored_sortable, type: :date)].should == today_str
      solr_doc[Solrizer.solr_name('desc_metadata__creator', :facetable)].should == ['Justin']
      solr_doc[Solrizer.solr_name('desc_metadata__creator')].should == ['Justin']
      solr_doc[Solrizer.solr_name('desc_metadata__part_of')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__date_uploaded')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__date_modified')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__rights')].should == ["Wide open, buddy."]
      solr_doc[Solrizer.solr_name('desc_metadata__related_url')].should be_nil
      solr_doc[Solrizer.solr_name('desc_metadata__contributor')].should == ["Martin Smith"]
      solr_doc[Solrizer.solr_name('desc_metadata__description')].should == ["An examination of retirement accounts. Included: the lack of uniformity in plans, which results in some workers paying much more than others; the cost of a seemingly small annual fee when spread out across a worker's lifetime; hidden fees some 401(k) providers charge consumers."]
      solr_doc[Solrizer.solr_name('desc_metadata__publisher')].should == ["Vertigo Comics"]
      solr_doc[Solrizer.solr_name('desc_metadata__subject')].should == ["Theology"]
      solr_doc[Solrizer.solr_name('desc_metadata__language')].should == ["Arabic"]
      solr_doc[Solrizer.solr_name('desc_metadata__date_created')].should == ["1200-01-01"]
      solr_doc[Solrizer.solr_name('desc_metadata__resource_type')].should == ["Book"]
      solr_doc[Solrizer.solr_name('file_format')].should == "jpeg (JPEG Image)"
      solr_doc[Solrizer.solr_name('desc_metadata__identifier')].should == ["1234567890"]
      # solr_doc[Solrizer.solr_name('desc_metadata__based_near')].should == ["Medina, Saudi Arabia"]
      solr_doc[Solrizer.solr_name('mime_type')].should == ["image/jpeg"]    
      solr_doc['unarranged_bsi'].should == true
      solr_doc['relative_path'].should == ['fortune/smiles/on/the/bold.mkv']    
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

  describe "#fix_mxf_characterization" do
    describe "with a file that is mxf" do
      before do
        subject.mime_type = 'application/octet-stream'
        subject.format_label = "Material Exchange Format"
      end
      it "should set the mime type" do
        subject.fix_mxf_characterization!
        subject.mime_type.should == 'application/mxf'
      end
    end
    describe "with a file that is not mxf" do
      before do
        subject.mime_type = 'application/octet-stream'
        subject.format_label = "Another format"
      end
      it "should not set the mime type" do
        subject.fix_mxf_characterization!
        subject.mime_type.should == 'application/octet-stream'
      end
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
      subject.title.build(value: "title one", title_type: 'Program')
      subject.title.build(value: "second title", title_type: 'Series')
      subject.title.build(value: "third title", title_type: 'Item')
      subject.title.build(value: "fourth title", title_type: 'Episode')
      subject.descMetadata.contributor.build(name: "Fred", role: "Carpenter")
      subject.descMetadata.creator.build(name: "Sally", role: "Author")
      subject.descMetadata.publisher.build(name: "Kelly", role: "Distributor")

      subject.subject = "Test subject"
      subject.description.build(type: 'summary', value: "Test summary")

      subject.event_location = ['France']
      subject.production_location = ['Boston']

      subject.date_portrayed = ["Sept 2009"]
      subject.resource_type = ['Scene']

      subject.language = ['Kiswahili', 'Lakota']

      subject.source = ['relationship source']
      subject.source_reference = ['relationship identifier']


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
      xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Program"]').text.should == "title one"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Series"]').text.should == "second title"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Item"]').text.should == "third title"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Episode"]').text.should == "fourth title"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreSubject').text.should == "Test subject"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreDescription[@annotation="Summary"]').text.should == "Test summary"

      # pbcoreDescriptionDocument/pbcoreCoverage[@ref='EVENT_LOCATION']
      xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Spatial"]/coverage[@annotation="EVENT_LOCATION"]').text.should == "France"

      # pbcoreDescriptionDocument/pbcoreCoverage[@ref='PRODUCTION_LOCATION']
      xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Spatial"]/coverage[@annotation="PRODUCTION_LOCATION"]').text.should == "Boston"

      # pbcoreDescriptionDocument/pbcoreCoverage[@ref='DATE_PORTRAYED']
      xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Temporal"]/coverage').text.should == "Sept 2009"

        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationLanguage[1]').text.should == 'Kiswahili'
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationLanguage[2]').text.should == 'Lakota'

      xml.xpath('/pbcoreDescriptionDocument/pbcoreRelation/pbcoreRelationType[@annotation="SOURCE"]').text.should == "relationship source"
      xml.xpath('/pbcoreDescriptionDocument/pbcoreRelation/pbcoreRelationIdentifier').text.should == "relationship identifier"


      xml.xpath('/pbcoreDescriptionDocument/pbcoreCreator[creatorRole="Author"]/creator').text.should == "Sally"
      #   TODO contributorrole Source is MARC?
      xml.xpath('/pbcoreDescriptionDocument/pbcoreContributor[contributorRole="Carpenter"]/contributor').text.should == "Fred"
      xml.xpath('/pbcoreDescriptionDocument/pbcorePublisher[publisherRole="Distributor"]/publisher').text.should == "Kelly"

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
      #
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
    describe "with audio data" do
      before do
        subject.ffprobe.content = '
            <ffprobe>
              <streams>
                <stream avg_frame_rate="0/0" bit_rate="768000" bits_per_sample="16" channels="1" codec_long_name="PCM signed 16-bit little-endian" codec_name="pcm_s16le" codec_tag="0x0001" codec_tag_string="[1][0][0][0]" codec_time_base="1/48000" codec_type="audio" duration="3583.318000" duration_ts="171999264" index="0" r_frame_rate="0/0" sample_fmt="s16" sample_rate="48000" time_base="1/48000">
                  <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
                </stream>
              </streams>
            </ffprobe>
            '

         subject.content.dsLocation = 'file:///opt/storage/one/two/three/fake.wav'
         subject.stub(:file_size).and_return(["343998572"])
         subject.stub(:audio?).and_return(true)
      end

      it "should have instantiation info" do
        str = subject.to_pbcore_xml
        xml = Nokogiri::XML(str)
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationIdentifier').text.should == subject.noid
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationLocation').text.should == "/opt/storage/one/two/three/fake.wav"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationDuration').text.should == "3583.318000"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationFileSize').text.should == "343998572"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationMediaType').text.should == "Sound"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackType').text.should == "Audio"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackDataRate').text.should == "768000"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackSamplingRate').text.should == "48000"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackBitDepth').text.should == "16"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackAnnotation').text.should == "1"

      end
    end
    describe "with video data" do
      before do
        subject.ffprobe.content = '<ffprobe>
  <streams>
    <stream avg_frame_rate="2997/100" bit_rate="900786" codec_long_name="H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10" codec_name="h264" codec_tag="0x31637661" codec_tag_string="avc1" codec_time_base="1/5994" codec_type="video" display_aspect_ratio="0:1" duration="128.762095" duration_ts="385900" has_b_frames="0" height="360" index="0" is_avc="1" level="30" nal_length_size="4" nb_frames="3859" pix_fmt="yuv420p" profile="Constrained Baseline" r_frame_rate="2997/100" sample_aspect_ratio="0:1" start_pts="0" start_time="0.000000" time_base="1/2997" width="480">
      <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
      <tag key="creation_time" value="2009-10-06 05:19:41"></tag>
      <tag key="language" value="eng"></tag>
      <tag key="handler_name" value="Apple Video Media Handler"></tag>
    </stream>
    <stream avg_frame_rate="0/0" bit_rate="100243" bits_per_sample="0" channels="2" codec_long_name="AAC (Advanced Audio Coding)" codec_name="aac" codec_tag="0x6134706d" codec_tag_string="mp4a" codec_time_base="1/44100" codec_type="audio" duration="128.777868" duration_ts="5679104" index="1" nb_frames="5546" r_frame_rate="0/0" sample_fmt="fltp" sample_rate="44100" start_pts="0" start_time="0.000000" time_base="1/44100">
      <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
      <tag key="creation_time" value="2009-10-06 05:19:41"></tag>
      <tag key="language" value="eng"></tag>
      <tag key="handler_name" value="Apple Sound Media Handler"></tag>
    </stream>
  </streams>
</ffprobe>'
         subject.content.dsLocation = 'file:///opt/storage/one/two/three/fake.m4v'
         subject.stub(:file_size).and_return(["16168799"])
         subject.stub(:video?).and_return(true)
      end
      it "should have instantiation info" do
        str = subject.to_pbcore_xml
        xml = Nokogiri::XML(str)
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationIdentifier').text.should == subject.noid
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationLocation').text.should == "/opt/storage/one/two/three/fake.m4v"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationDuration').text.should == "128.762095"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationFileSize').text.should == "16168799"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationMediaType').text.should == "Moving Image"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackType').text.should == "Video"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackStandard').text.should == "H.264/MPEG-4 AVC"
        # TODO - how will we get the essenceTrackEncoding that matches the vocabulary?
        #xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackEncoding').text.should == "H.264/MPEG-4 AVC"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackDataRate').text.should == "900786"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackFrameRate').text.should == "2997/100"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackFrameSize').text.should == "480x360"

        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackType').text.should == "Audio"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackStandard').text.should == "AAC"
        #xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackEncoding').text.should == "H.264/MPEG-4 AVC"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackDataRate').text.should == "100243"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackSamplingRate').text.should == "44100"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackBitDepth').text.should == "0"
        xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackAnnotation').text.should == "2"
      end
    end
  end


end
