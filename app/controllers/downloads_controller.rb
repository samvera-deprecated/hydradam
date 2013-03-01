class DownloadsController < ApplicationController
  include Sufia::DownloadsControllerBehavior

  after_filter :log_download, :only=>:show

  def show
    if can? :read, params[:id]
      @asset = ActiveFedora::Base.find(params[:id], :cast=>true)
      # we can now examine @asset and determine if we should send_content, or some other action.
      if over_threshold?
        @ftp_link =@asset.export_to_ftp(request.host)
      else
        send_content (@asset)
      end
    else 
      logger.info "[DownloadsController] #{current_user.user_key} does not have access to read #{params['id']}"
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
      raise ActionController::RoutingError.new('Not Found') if ds.nil? or !ds.has_content?
      opts[:type] = ds.mimeType
      # ds.filename is only for externals
      if (ds.respond_to? :filename)
        send_file ds.filename, opts
      else
        send_data ds.content, opts
      end
      return
  end

  private

  def over_threshold?
    @asset.file_size.first.to_i > Bawstun::Application.config.ftp_download_threshold
  end
   

end
