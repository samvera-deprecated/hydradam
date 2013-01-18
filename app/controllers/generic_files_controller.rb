class GenericFilesController < ApplicationController
  include Sufia::FilesControllerBehavior

  after_filter :log_visit, :only=>:show

  def log_visit
    @generic_file.views.create!(user: current_user)
  end

  # routed to /files (POST)
  def create
    if params[:local_file].present?
      if (ingest_local_file)
        redirect_to sufia.batch_edit_path(params[:batch_id])
      else
        flash[:alert] = "Error creating generic file."
        render :new
      end
    else
      # They are uploading files.
      super
    end
  end

  private

  def ingest_local_file
    # Ingest files already on disk
    filename = params[:local_file][0]
    params[:local_file].each do |filename|
      Sufia.queue.push(IngestLocalFileJob.new(current_user.directory, filename, current_user.user_key, params[:batch_id]))
    end
    true
  end


end
