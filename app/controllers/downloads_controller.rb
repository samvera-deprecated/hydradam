class DownloadsController < ApplicationController
  include Sufia::DownloadsControllerBehavior

  after_filter :log_download, :only=>:show

  def show
    if can? :read, params[:id]
      @asset = ActiveFedora::Base.find(params[:id], :cast=>true)
      # we can now examine @asset and determine if we should send_content, or some other action.
      if over_threshold?
        @ftp_link =export_to_ftp(@asset)
      else
        send_content (@asset)
      end
    else 
      logger.info "Can not read #{params['id']}"
      redirect_to "/assets/NoAccess.png"
    end
  end

  def log_download
    @asset.downloads.create!(user: current_user) unless ['thumbnail', 'webm', 'mp4'].include?(params[:datastream_id])
  end

  protected

  # Overriding so that we can use with external datastreams
  def send_content (asset)
      opts = {}
      ds = nil
      opts[:filename] = params["filename"] || asset.label
      opts[:disposition] = 'inline' 
      if params.has_key?(:datastream_id)
        opts[:filename] = params[:datastream_id]
        ds = asset.datastreams[params[:datastream_id]]
      end
      ds = default_content_ds(asset) if ds.nil?
      raise ActionController::RoutingError.new('Not Found') if ds.nil?
      opts[:type] = ds.mimeType
      send_file ds.filename, opts
      return
  end

  private

  def over_threshold?
    @asset.file_size.first.to_i > Bawstun::Application.config.ftp_download_threshold
  end
   
  # Copy the content datastream to a file in the download ftp location
  # TODO need a way to sweep these files up.
  def export_to_ftp(asset)
    filename = asset.filename.first
    path, key = obscure_directory(asset.pid, filename)
    File.open(path, 'wb') do |f|
      f.write asset.content.content
    end
    ftp_path(key, filename)
  end

  def ftp_path(directory, filename)
    "ftp://#{request.host}/#{directory}/#{filename}"
  end

  def obscure_directory(id, filename)
    begin
      key = unique_key(id)
      base = Bawstun::Application.config.ftp_download_base
      dirname = File.join(base, key)
    end while File.exist?(dirname)
    Dir.mkdir(dirname)
    [File.join(dirname,filename), key]
  end

  def unique_key(id)
    key = Digest::SHA2.new << (DateTime.now.to_f.to_s + id)
    key.to_s
  end

end
