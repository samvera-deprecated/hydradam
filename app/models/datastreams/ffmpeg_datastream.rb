class FfmpegDatastream < ActiveFedora::OmDatastream
  
  set_terminology do |t|
    t.root(:path => "ffprobe")
    t.streams {
      t.stream {
        t.index(:path=>{:attribute=>"index"})
        t.codec_name(:path=>{:attribute=>"codec_name"})
        t.duration(:path=>{:attribute=>"duration"})
        t.width(:path=>{:attribute=>"width"})
        t.height(:path=>{:attribute=>"height"})
      }
    }
  end

  def self.xml_template
    Nokogiri::XML.parse("<ffprobe/>")
  end
end
