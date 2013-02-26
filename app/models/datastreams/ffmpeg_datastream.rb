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
        t.codec_type(:path=>{:attribute=>"codec_type"})
        t.duration(:path=>{:attribute=>"duration"})
        t.width(:path=>{:attribute=>"width"})
        t.height(:path=>{:attribute=>"height"})
      }
    }

    t.duration(proxy: [:streams, :stream, :duration])
    t.bit_rate(proxy: [:streams, :stream, :bit_rate])
    t.bits_per_sample(proxy: [:streams, :stream, :bits_per_sample])
    t.sample_rate(proxy: [:streams, :stream, :sample_rate])
    t.codec_type(proxy: [:streams, :stream, :codec_type])
    t.channels(proxy: [:streams, :stream, :channels])
  end

  def self.xml_template
    Nokogiri::XML.parse("<ffprobe/>")
  end
end
