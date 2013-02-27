class FfmpegDatastream < ActiveFedora::OmDatastream
  
  set_terminology do |t|
    t.root(:path => "ffprobe")
    t.streams {
      t.stream {
        t.index(:path=>{:attribute=>"index"})
        t.channels(:path=>{:attribute=>"channels"})
        t.bit_rate(:path=>{:attribute=>"bit_rate"})
        t.bits_per_sample(:path=>{:attribute=>"bits_per_sample"})
        t.sample_rate(:path=>{:attribute=>"sample_rate"})
        t.codec_name(:path=>{:attribute=>"codec_name"})
        t.codec_long_name(:path=>{:attribute=>"codec_long_name"})
        t.codec_type(:path=>{:attribute=>"codec_type"})
        t.duration(:path=>{:attribute=>"duration"})
        t.width(:path=>{:attribute=>"width"})
        t.height(:path=>{:attribute=>"height"})
        t.frame_rate(:path=>{:attribute=>"avg_frame_rate"})
      }
    }

    t.duration(proxy: [:streams, :stream, :duration])
    t.bit_rate(proxy: [:streams, :stream, :bit_rate])
    t.bits_per_sample(proxy: [:streams, :stream, :bits_per_sample])
    t.sample_rate(proxy: [:streams, :stream, :sample_rate])
    t.codec_type(proxy: [:streams, :stream, :codec_type])
    t.codec_long_name(proxy: [:streams, :stream, :codec_long_name])
    t.codec_name(proxy: [:streams, :stream, :codec_name])
    t.channels(proxy: [:streams, :stream, :channels])
    t.frame_rate(proxy: [:streams, :stream, :frame_rate])
  end

  def self.xml_template
    Nokogiri::XML.parse("<ffprobe/>")
  end
end
