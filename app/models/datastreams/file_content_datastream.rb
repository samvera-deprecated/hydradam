class FileContentDatastream < ActiveFedora::Datastream
  include Sufia::FileContent::ExtractMetadata
  include Sufia::FileContent::Versions

  def extract_metadata
    out = [] 
    to_tempfile do |f|
      out << run_fits!(f.path)
      out << run_ffprobe!(f.path)
    end
    out
  end

  private

  def run_ffprobe!(file_path)
    out = nil
    command = "#{ffprobe_path} -i #{file_path} -print_format xml -show_streams -v quiet"
    stdin, stdout, stderr = popen3(command)
    stdin.close
    out = stdout.read
    stdout.close
    err = stderr.read
    stderr.close
    raise "Unable to execute command \"#{command}\"\n#{err}" unless err.empty?
    out
  end

  def ffprobe_path
    'ffprobe'
  end

end
