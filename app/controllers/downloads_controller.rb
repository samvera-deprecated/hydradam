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
        if request.headers["Range"].present?
          logger.info "[DownloadsController] Range? #{request.headers["Range"]}"
          stream(@asset)
        else
          send_content(@asset)
        end
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

  def stream(asset)
    ds = asset.datastreams[datastream_name]
    response.headers['Accept-Ranges'] = 'bytes'

    if request.head?
      logger.info("Got a head request for streaming")
      # content length header
      response.headers['Content-Length'] = ds.dsSize
      response.headers['Content-Type'] = ds.mimeType
      return head :ok
    end
    
    _, range = request.headers["Range"].split('bytes=')
    from, to = range.split('-').map(&:to_i)
    to = ds.dsSize unless to
    repo = ds.send(:repository) # TODO find a better way.
    buffer = StringIO.new
    repo.datastream_dissemination(pid: asset.pid, dsid: datastream_name) do |response|
      response.read_body do |chunk|
        # TODO discard the parts before from
        buffer.write(chunk)
      end
    end
    buffer.close_write
    buffer.seek(from||0)

    length = to - from
    length = 1 if length == 0
    response.headers['Content-Range'] = "bytes #{from}-#{to}/#{ds.dsSize}"
    response.headers['Content-Length'] = "#{length}"

    send_data buffer.read(length), content_options(asset, ds)
  end

  # Overriding so that we can use with external datastreams
  def send_content(asset)
    ds = asset.datastreams[datastream_name]
    raise ActionController::RoutingError.new('Not Found') if ds.nil? or !ds.has_content?
    # ds.filename is only for externals
    if (ds.respond_to? :filename)
      send_file ds.filename, content_options(asset, ds)
    else
      send_data ds.content, content_options(asset, ds)
    end
  end

  def content_options(asset, ds)
    opts = {disposition: 'inline'}
    if default_datastream?
      opts[:filename] = params["filename"] || asset.label
    else
      opts[:filename] = params[:datastream_id]
    end

    opts[:type] = ds.mimeType
    opts
  end

  private

  def over_threshold?
    @asset.file_size.first.to_i > Bawstun::Application.config.ftp_download_threshold
  end
   

end
