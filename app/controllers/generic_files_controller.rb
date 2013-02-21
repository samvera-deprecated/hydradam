class GenericFilesController < ApplicationController
  include Sufia::FilesControllerBehavior

  after_filter :log_visit, :only=>:show

  def log_visit
    @generic_file.views.create!(user: current_or_guest_user)
  end

  # routed to /files/:id
  def show
    respond_to do |format|
      format.html {
        @events = @generic_file.events(100)
      }
      format.xml { render :xml => @generic_file.to_pbcore_xml }
    end
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
      @generic_file = GenericFile.new
      Sufia::GenericFile::Actions.create_metadata(@generic_file, current_user, params[:batch_id] )
      Sufia.queue.push(IngestLocalFileJob.new(@generic_file.id, current_user.directory, filename, current_user.user_key))
    end
    true
  end


end
