require 'spec_helper'

describe GenericFile do
  describe "characterize" do
    before do
      subject.apply_depositor_metadata('frank')
      subject.stub(noid: 'abcdefg')
      subject.add_file(File.open(fixture_path + '/sample.mov', 'rb'), 'content', 'sample.mov')
    end
    it "should get fits and ffprobe metadata", unless: $in_travis do
      subject.characterize
      expect(subject.characterization.mime_type.to_a).to include "video/quicktime"
      expect(subject).to be_video
    end
  end

  describe "append_metadata" do
    before do
      subject.file_title = ['test1', 'test2']
      subject.file_author = ['author1', 'author2']
      subject.creator = ['author3', 'author4']
      subject.title = ['title3', 'title4']
    end
    it "should append each term only once" do
      expect(subject.creator.map(&:name).flatten).to eq ['author3', 'author4']
      subject.append_metadata
      expect(subject.title.map(&:value).flatten).to eq ['title3', 'title4', 'test1', 'test2']
      expect(subject.creator.map(&:name).flatten).to eq ['author3', 'author4', 'author1', 'author2']
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
      its(:video?) { should eq true}
      its(:audio?) { should eq false}
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
      its(:video?) { should eq false}
      its(:audio?) { should eq true}
    end
  end

  describe "terms_for_editing" do
    it "should return a list" do
      expect(subject.terms_for_editing).to eq [ :contributor, :creator, :title, :description, 
        :event_location, :production_location, :date_portrayed, :source, :source_reference,
        :rights_holder, :rights_summary, :publisher, :date_created, :release_date, :review_date,
        :aspect_ratio, :frame_rate, :cc, :physical_location, :identifier, :metadata_filename,
        :notes, :originating_department, :subject, :language, :rights, :resource_type, :tag,
        :related_url]
    end
  end
  describe "terms_for_display" do
    it "should return a list" do
      expect(subject.terms_for_display).to eq [ :part_of, :contributor, :creator, :title, :description, 
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
      expect(subject.descMetadata.contributor.first.name).to eq ["Sally"]
      expect(subject.descMetadata.contributor.last.name).to eq ["Mary"]
      expect(subject.contributor.first).to be_kind_of MediaAnnotationDatastream::Person
      expect(subject.contributor.first.name.first).to eq "Sally"
    end
  end
  describe "publisher attribute" do
    it "should delegate to the bnode" do
      subject.publisher_attributes = [{name: "Sally"}, {name:"Mary"}]
      expect(subject.descMetadata.publisher.first.name).to eq ["Sally"]
      expect(subject.descMetadata.publisher.last.name).to eq ["Mary"]
      expect(subject.publisher.first).to be_kind_of MediaAnnotationDatastream::Person
      expect(subject.publisher.first.name.first).to eq "Sally"
    end
  end

  describe "creator attribute" do
    it "should delegate to the bnode" do
      subject.creator_attributes = [{name: "Sally"}, {name:"Mary"}]
      expect(subject.descMetadata.creator.first.name).to eq ["Sally"]
      expect(subject.descMetadata.creator.last.name).to eq ["Mary"]
      expect(subject.creator.first).to be_kind_of MediaAnnotationDatastream::Person
      expect(subject.creator.first.name.first).to eq "Sally"
    end
  end

  describe "description attribute" do
    it "should delegate to the bnode" do
      subject.description_attributes = [{value: "Order online", type:"Promotional Information"}]
      expect(subject.description.first.value).to eq ["Order online"]
      expect(subject.description.first.type).to eq ["Promotional Information"]
      expect(subject.description.first).to be_kind_of MediaAnnotationDatastream::Description
    end
  end

  describe "event location" do
    before do
      subject.event_location = ["one", "two"]
    end
    it "should delegate to the bnode" do
      expect(subject.filming_event.has_location[0].location_name).to eq ['one']
      expect(subject.filming_event.has_location[1].location_name).to eq ['two']
    end
  end
  describe "production location" do
    before do
      subject.production_location = ["one", "two"]
    end
    it "should delegate to the bnode" do
      expect(subject.production_event.has_location[0].location_name).to eq ['one']
      expect(subject.production_event.has_location[1].location_name).to eq ['two']
    end
  end

  describe "unarranged" do
    after do
      subject.delete
    end
    it "should have it" do
      expect(subject.unarranged).to be_nil
      subject.unarranged = true
      subject.save(validate: false)
      expect(subject.reload.unarranged).to eq true
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
      subject.stub(pid: 'testme:123')
      solr_doc = subject.to_solr
      expect(solr_doc[Solrizer.solr_name('desc_metadata__series_title')]).to eq ["Frontline"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__program_title')]).to eq ["The Retirement Gamble"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__episode_title')]).to eq ["12"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__title')]).to eq ["The Retirement Gamble"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__date_modified', :stored_sortable, type: :date)]).to eq today_str
      expect(solr_doc[Solrizer.solr_name('desc_metadata__date_uploaded', :stored_sortable, type: :date)]).to eq today_str
      expect(solr_doc[Solrizer.solr_name('desc_metadata__creator', :facetable)]).to eq ['Justin']
      expect(solr_doc[Solrizer.solr_name('desc_metadata__creator')]).to eq ['Justin']
      expect(solr_doc[Solrizer.solr_name('desc_metadata__part_of')]).to be_nil
      expect(solr_doc[Solrizer.solr_name('desc_metadata__date_uploaded')]).to be_nil
      expect(solr_doc[Solrizer.solr_name('desc_metadata__date_modified')]).to be_nil
      expect(solr_doc[Solrizer.solr_name('desc_metadata__rights')]).to eq ["Wide open, buddy."]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__related_url')]).to be_nil
      expect(solr_doc[Solrizer.solr_name('desc_metadata__contributor')]).to eq ["Martin Smith"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__description')]).to eq ["An examination of retirement accounts. Included: the lack of uniformity in plans, which results in some workers paying much more than others; the cost of a seemingly small annual fee when spread out across a worker's lifetime; hidden fees some 401(k) providers charge consumers."]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__publisher')]).to eq ["Vertigo Comics"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__subject')]).to eq ["Theology"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__language')]).to eq ["Arabic"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__date_created')]).to eq ["1200-01-01"]
      expect(solr_doc[Solrizer.solr_name('desc_metadata__resource_type')]).to eq ["Book"]
      expect(solr_doc[Solrizer.solr_name('file_format')]).to eq "jpeg (JPEG Image)"
      expect(solr_doc[Solrizer.solr_name('desc_metadata__identifier')]).to eq ["1234567890"]
      # expect(solr_doc[Solrizer.solr_name('desc_metadata__based_near')]).to eq ["Medina, Saudi Arabia"]
      expect(solr_doc[Solrizer.solr_name('mime_type')]).to eq ["image/jpeg"]    
      expect(solr_doc['unarranged_bsi']).to eq true
      expect(solr_doc['relative_path']).to eq ['fortune/smiles/on/the/bold.mkv']    
      # expect(solr_doc[Solrizer.solr_name('noid', :symbol)]).to eq "__DO_NOT_USE__"
      expect(solr_doc["noid_tsi"]).to eq "123"
    end

  end


  describe "#depositor" do
    it "should be there" do
      subject.apply_depositor_metadata('frank')
      expect(subject.depositor).to eq 'frank'
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
        expect(subject.mime_type).to eq 'application/mxf'
      end
    end
    describe "with a file that is not mxf" do
      before do
        subject.mime_type = 'application/octet-stream'
        subject.format_label = "Another format"
      end
      it "should not set the mime type" do
        subject.fix_mxf_characterization!
        expect(subject.mime_type).to eq 'application/octet-stream'
      end
    end
  end

  describe "#add_external_file" do
    before do
      subject.apply_depositor_metadata('frank')
      subject.stub(noid: 'abcdefg')
      subject.stub(:characterize_if_changed).and_yield #don't run characterization
      FileUtils.copy(File.join(fixture_path + '/sample.mov'), File.join(fixture_path + '/my sample.mov'))
      subject.add_external_file(fixture_path + '/my sample.mov', 'content', 'my sample.mov')
    end

    it "should handle files with spaces in them" do
      # store the URI with spaces escaped to %20
      expect(subject.content.dsLocation).to match /^file:\/\/.*\/ab\/cd\/ef\/g\/my%20sample.mov$/
      # But filename should unescape
      expect(subject.content.filename).to match /^\/.*\/ab\/cd\/ef\/g\/my sample.mov$/
    end

    it "should set the label" do
      expect(subject.label).to eq 'my sample.mov'

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

      subject.rights_holder = ["Test rights holder"]
      subject.rights_summary = ["Test rights summary"]

      subject.date_created = ['2013-08-15']

      subject.release_date = ['2013-08-31']
      subject.review_date = ['2014-08-31']


      subject.aspect_ratio = ['3:5']

      subject.cc = ['French']

      subject.physical_location = ['On the shelf']

      subject.identifier.build(value: "Test nola", identifier_type: 'NOLA_CODE')
      subject.identifier.build(value: "Test tape id", identifier_type: 'ITEM_IDENTIFIER')
      subject.identifier.build(value: "Test barcode", identifier_type: 'PO_REFERENCE')

      subject.notes = ["Test notes"]

      subject.originating_department = ["Test originating department"]

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
      xml = Nokogiri::XML(str)
      # program title
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Program"]').text).to eq "title one"
      # series title
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Series"]').text).to eq "second title"

      # item title
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Item"]').text).to eq "third title"

      # episode title
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreTitle[@titleType="Episode"]').text).to eq "fourth title"

      # category
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreSubject').text).to eq "Test subject"

      # summary
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreDescription[@annotation="Summary"]').text).to eq "Test summary"

      # event_location
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Spatial"]/coverage[@annotation="EVENT_LOCATION"]').text).to eq "France"

      # production_location 
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Spatial"]/coverage[@annotation="PRODUCTION_LOCATION"]').text).to eq "Boston"

      # date_portrayed
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Temporal"]/coverage[@annotation="DATE_PORTRAYED"]').text).to eq "Sept 2009"

      # language
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationLanguage[1]').text).to eq 'Kiswahili'
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationLanguage[2]').text).to eq 'Lakota'

      # source
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreRelation/pbcoreRelationType[@annotation="SOURCE"]').text).to eq "relationship source"

      # source_reference 
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreRelation/pbcoreRelationIdentifier').text).to eq "relationship identifier"

      # rights_holder
      expect(xml.xpath('/pbcoreDescriptionDocument/rightsEmbedded/WGBH_RIGHTS/@RIGHTS_HOLDER').text).to eq "Test rights holder"

      # rights_summary
      expect(xml.xpath('/pbcoreDescriptionDocument/rightsEmbedded/WGBH_RIGHTS/@RIGHTS').text).to eq "Test rights summary"

      # item_date
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreAssetDate').text).to eq "2013-08-15"

      # release_date
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreExtension[@annotation="Release date information"]/WGBH_DATE_RELEASE/@DATE_RELEASE').text).to eq "2013-08-31"

      # review_date
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreExtension[@annotation="Lifecycle information"]/WGBH_DATE/@REVIEW_DATE').text).to eq "2014-08-31"

      # aspect_ratio
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackAspectRatio').text).to eq "3:5"

      # cc
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/instantiationAlternativeModes').text).to eq "CC in French"

      # physical_location
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationLocation').text).to eq "On the shelf"

      # nola_code
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreIdentifier[@source="NOLA_CODE"]').text).to eq "Test nola"

      # tape_id
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreIdentifier[@source="ITEM_IDENTIFIER"]').text).to eq "Test tape id"

      # barcode
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreIdentifier[@source="PO_REFERENCE"]').text).to eq "Test barcode"

      # notes
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreAnnotation').text).to eq "Test notes"

      # originating_department
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreExtension[@annotation="Originating department information"]/WGBH_META/@META_SOURCE').text).to eq "Test originating department"

      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreCreator[creatorRole="Author"]/creator').text).to eq "Sally"
      #   TODO contributorrole Source is MARC?
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreContributor[contributorRole="Carpenter"]/contributor').text).to eq "Fred"
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcorePublisher[publisherRole="Distributor"]/publisher').text).to eq "Kelly"

      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreCoverage[coverageType="Temporal"]/coverage').text).to eq "Sept 2009"
      
      # pbcoreAssetType
      expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreAssetType').text).to eq "Scene"
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
         subject.stub(:noid => 'abcdefg')
      end

      it "should have instantiation info" do
        str = subject.to_pbcore_xml
        xml = Nokogiri::XML(str)
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationIdentifier[@source="HydraDAM"]').text).to eq subject.noid
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationIdentifier[@source="Original file name"]').text).to eq "/opt/storage/one/two/three/fake.wav"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationDuration').text).to eq "3583.318000"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationFileSize').text).to eq "343998572"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationMediaType').text).to eq "Sound"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackType').text).to eq "Audio"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackDataRate').text).to eq "768000"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackSamplingRate').text).to eq "48000"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackBitDepth').text).to eq "16"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack/essenceTrackAnnotation').text).to eq "1"

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
         subject.stub(:noid => 'abcdefg')
      end
      it "should have instantiation info" do
        str = subject.to_pbcore_xml
        xml = Nokogiri::XML(str)
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationIdentifier[@source="HydraDAM"]').text).to eq subject.noid
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationIdentifier[@source="Original file name"]').text).to eq "/opt/storage/one/two/three/fake.m4v"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationDuration').text).to eq "128.762095"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationFileSize').text).to eq "16168799"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationMediaType').text).to eq "Moving Image"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackType').text).to eq "Video"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackStandard').text).to eq "H.264/MPEG-4 AVC"
        # TODO - how will we get the essenceTrackEncoding that matches the vocabulary?
        # expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackEncoding').text).to eq "H.264/MPEG-4 AVC"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackDataRate').text).to eq "900786"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackFrameRate').text).to eq "2997/100"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[1]/essenceTrackFrameSize').text).to eq "480x360"

        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackType').text).to eq "Audio"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackStandard').text).to eq "AAC"
        # expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackEncoding').text).to eq "H.264/MPEG-4 AVC"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackDataRate').text).to eq "100243"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackSamplingRate').text).to eq "44100"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackBitDepth').text).to eq "0"
        expect(xml.xpath('/pbcoreDescriptionDocument/pbcoreInstantiation/instantiationEssenceTrack[2]/essenceTrackAnnotation').text).to eq "2"
      end
    end
  end


end
