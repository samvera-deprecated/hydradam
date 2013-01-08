class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  def log_events
    TrackingEvent.where(pid: pid)
  end

  def views
    log_events.where(event: 'view')
  end

  def downloads
    log_events.where(event: 'download')
  end

  def characterize
    super
    ffprobe if video?
  end

  private

  def ffprobe
    out = nil
    f.content.to_tempfile do |f|
      command = "#{ffprobe_path} -i #{f.path}"
      stdin, stdout, stderr = popen3(command)
      stdin.close
      out = stdout.read
      stdout.close
      err = stderr.read
      stderr.close
      raise "Unable to execute command \"#{command}\"\n#{err}" unless err.empty?
    end
    out
  end
end
