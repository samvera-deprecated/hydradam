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


  protected

  # overridding this method because we don't want to enfoce that terms are accepted. 
  def terms_accepted?
    true
  end

  # overriding this method to initialize more complex RDF assertions (b-nodes)
  def initialize_fields(file)
    file.publisher.build if file.publisher.empty?
    file.contributor.build if file.contributor.empty?
    file.creator.build if file.creator.empty?
    file.has_location.build if file.has_location.empty?
    super
  end
  

  private

  def ingest_local_file
    # Ingest files already on disk
    filename = params[:local_file][0]
    params[:local_file].each do |filename|
      @generic_file = GenericFile.new
      #TODO Test this
      @generic_file.set_title_and_label( filename, :only_if_blank=>true )
      Sufia::GenericFile::Actions.create_metadata(@generic_file, current_user, params[:batch_id] )
      Sufia.queue.push(IngestLocalFileJob.new(@generic_file.id, current_user.directory, filename, current_user.user_key))
    end
    true
  end


end
