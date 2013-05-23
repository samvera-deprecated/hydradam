class DownloadsController < ApplicationController
  include Sufia::DownloadsControllerBehavior

  after_filter :log_download, :only=>:show

  def show
    if can? :read, params[:id]
      @asset = ActiveFedora::Base.find(params[:id], :cast=>true)

      if default_datastream?
        if @asset.content.live?
          # we can now examine @asset and determine if we should send_content, or some other action.
          if over_threshold?
            @ftp_link =@asset.export_to_ftp(request.host)
          else
            send_content (@asset)
          end
        else
          # we can now examine @asset and determine if we should send_content, or some other action.
          @asset.content.online!(current_user)
          render 'offline'
        end
      else
        # A proxy datastream
        send_content(@asset)
      end
    else 
      logger.info "[DownloadsController] #{current_user ? current_user.user_key : 'anonymous user'} does not have access to read #{params['id']}"
      redirect_to "/assets/NoAccess.png"
    end
  end

  def log_download
    if @asset
      @asset.downloads.create!(user: current_user) unless ['thumbnail', 'webm', 'mp4'].include?(params[:datastream_id])
    end
  end

  protected

  # Overriding so that we can use with external datastreams
  def send_content(asset)
    response.headers['Accept-Ranges'] = 'bytes'

    if request.head?
      content_head
    elsif request.headers["Range"]
      send_range
    elsif (datastream.respond_to? :filename)
      send_file datastream.filename, content_options
    else
      send_file_headers! content_options
      self.response_body = datastream.stream
    end
  end

  def datastream_name
    default_datastream? ? super : params[:datastream_id]
  end

  private

  def default_datastream?
    datastream.dsid == self.class.default_content_dsid
  end

  def over_threshold?
    @asset.file_size.first.to_i > Bawstun::Application.config.ftp_download_threshold
  end
   

end
