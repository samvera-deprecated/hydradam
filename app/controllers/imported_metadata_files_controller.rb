class ImportedMetadataFilesController < ApplicationController
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier
  load_and_authorize_resource :class => ImportedMetadata, :instance_name =>:imported_metadata

  # Blacklight-Based Query Support
  include Blacklight::SolrHelper
  include Blacklight::Configurable # comply with BL 3.7
  # This is needed as of BL 3.7
  self.copy_blacklight_config_from(CatalogController)
  # before_filter :default_query_to_calculated_filepath
  ImportedMetadataFilesController.solr_search_params_logic = [:default_query_to_calculated_filepath, :add_query_to_solr,:add_facet_fq_to_solr, :add_facetting_to_solr, :add_solr_fields_to_query, :add_paging_to_solr, :add_sorting_to_solr, :only_query_path]
  before_filter :query_matches, only: [:show]
  
  configure_blacklight do |config|
    config.add_facet_field "unarranged_ssim", :label => "Already Arranged?", :limit => 3
  end
  
  
  #show
  def show
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

  def apply
    @imported_metadata.apply_to = params[:imported_metadata][:apply_to]
    @imported_metadata.apply!
    redirect_to imported_metadata_manager_index_path, notice: "Template is now being applied"
  end
  
  private
  
  def query_matches
    (@matches_response, @matches) = get_search_results
    @filters = params[:f] || []
  end
  
  def only_query_path solr_parameters, user_parameters
    solr_parameters[:q] = "relative_path:\"#{solr_parameters[:q]}\" OR noid_tsi:\"#{solr_parameters[:q]}\""
  end
  
  def default_query_to_calculated_filepath solr_parameters, user_parameters
    user_parameters[:q] = @imported_metadata.match_files_with_path unless params[:q] && !params[:q].empty?
    # default to returning only unarranged
    # params[:f] = 
  end
  
  def blacklight_solr
    @solr ||=  RSolr.connect(blacklight_solr_config)
  end

  def blacklight_solr_config
    Blacklight.solr_config
  end
  
end
