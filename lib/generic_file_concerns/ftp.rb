module GenericFileConcerns
  module Ftp
    extend ActiveSupport::Concern
    # Copy the content datastream to a file in the download ftp location
    # TODO need a way to sweep these files up.
    def export_to_ftp(host)
      filename = self.filename.first
      path, key = obscure_directory(filename)
      if content.external?
        FileUtils.ln_s(File.expand_path(content.filename), path)
      else
        File.open(path, 'wb') do |f|
          f.write content.content
        end
      end
      ftp_path(host, key, filename)
    end

    def ftp_path(host, directory, filename)
      "ftp://#{host}/#{directory}/#{filename}"
    end

    def obscure_directory(filename)
      begin
        key = unique_key()
        base = Bawstun::Application.config.ftp_download_base
        dirname = File.join(base, key)
      end while File.exist?(dirname)
      Dir.mkdir(dirname)
      [File.join(dirname,filename), key]
    end

    def unique_key
      key = Digest::SHA2.new << (DateTime.now.to_f.to_s + pid)
      key.to_s
    end

  end
end
