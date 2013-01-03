class DownloadsController < ApplicationController
  include Sufia::DownloadsControllerBehavior

  after_filter :log_download, :only=>:show

  def log_download
    @asset.downloads.create!(user: current_user)
  end

end
