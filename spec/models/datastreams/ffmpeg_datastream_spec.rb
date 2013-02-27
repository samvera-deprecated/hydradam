require 'spec_helper'

describe FfmpegDatastream do
  describe "with an audio track" do
    subject do
      #mock_obj = stub(:mock_obj, :pid=>'test:124', :new? => true)
      ds = FfmpegDatastream.new#(mock_obj)
      ds.content = '
              <ffprobe>
                <streams>
                  <stream avg_frame_rate="0/0" bit_rate="768000" bits_per_sample="16" channels="1" codec_long_name="PCM signed 16-bit little-endian" codec_name="pcm_s16le" codec_tag="0x0001" codec_tag_string="[1][0][0][0]" codec_time_base="1/48000" codec_type="audio" duration="3583.318000" duration_ts="171999264" index="0" r_frame_rate="0/0" sample_fmt="s16" sample_rate="48000" time_base="1/48000">
                    <disposition attached_pic="0" clean_effects="0" comment="0" default="0" dub="0" forced="0" hearing_impaired="0" karaoke="0" lyrics="0" original="0" visual_impaired="0"></disposition>
                  </stream>
                </streams>
              </ffprobe>
              '
      ds
    end


    its (:duration) { should == ["3583.318000"]}
    its (:bit_rate) { should == ["768000"]}
    its (:bits_per_sample) { should == ["16"]}
    its (:sample_rate) { should == ["48000"]}
    its (:channels) { should == ["1"]}
    its (:codec_type) { should == ["audio"]}
    its (:frame_rate) { should == ["0/0"]}
    its (:codec_long_name) { should == ["PCM signed 16-bit little-endian"]}
    its (:codec_name) { should == ["pcm_s16le"]}
  end
end
