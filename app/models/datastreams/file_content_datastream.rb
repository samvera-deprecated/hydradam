class FileContentDatastream < ActiveFedora::Datastream
  include Sufia::FileContent::ExtractMetadata
  include Sufia::FileContent::Versions

  before_destroy :remove_content

  def extract_metadata
    out = [] 
    to_tempfile do |f|
      out << run_fits!(f.path)
      out << run_ffprobe!(f.path)
    end
    out
  end

  # The internal method is just checking that the datastream stored in Fedora is
  # valid.  Here we check that the file stored in the filesystem is valid too if
  # this file is stored on the filesystem.
  def dsChecksumValid
    super && (!external? || file_checksum_valid?)
  end

  def file_checksum_valid?
    # puts "Calculated: #{calculate_file_checksum}"
    # puts "Stored: #{stored_file_checksum}"
    calculate_file_checksum == stored_file_checksum
  end

  def stored_file_checksum
    GenericFile.find(pid).original_checksum.first
  end

  def calculate_file_checksum
    Digest::MD5.file(filename).hexdigest
  end

  def remove_content
    if has_content? && live?
      File.unlink filename
    else
      false # can't remove the file until the content is live.
    end
  end

  def live?
    storage_manager.live?(filename)
  end

  def external?
    super
  end

  def online!(user)
    storage_manager.bring_online(filename)
    req = FileRequest.new
    req.pid = pid
    req.user = user
    req.save!
  end

  def filename
    URI.unescape(dsLocation).sub('file://', '') if dsLocation
  end

  # Override so that we can use external files.
  def has_content?
    dsLocation.present? && File.exists?(filename)
  end

  # Override so that we can use external files.
  def to_tempfile &block
    return unless has_content?
    yield(File.open(filename, 'rb'))
  end

  private

  def storage_manager
    @storage_manager ||= Rails.configuration.storage_manager.constantize
  end

  def run_ffprobe!(file_path)
    out = nil
    command = "#{ffprobe_path} -i \"#{file_path}\" -print_format xml -show_streams -v quiet"
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
