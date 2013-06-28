class ImportedMetadataFilesController < ApplicationController
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier
  load_and_authorize_resource :class => ImportedMetadata, :instance_name =>:imported_metadata
  
  #show
  def show
    @matches = @imported_metadata.matching_files
  end
  
  #edit
  def edit
  end
  
  #destroy
  def destroy
    pid = @imported_metadata.noid
    @imported_metadata.destroy
    Sufia.queue.push(ContentDeleteEventJob.new(pid, current_user.user_key))
    redirect_to imported_metadata_manager_index_path, notice: render_to_string(:partial=>'generic_files/asset_deleted_flash', :locals => { :generic_file => @imported_metadata })
  end

  def update
    @imported_metadata.update_attributes(params[:imported_metadata])
    redirect_to imported_metadata_file_path(@imported_metadata), notice: "Template has been updated"
  end
  
end
