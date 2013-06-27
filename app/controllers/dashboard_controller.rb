require 'blacklight/catalog'
class DashboardController < ApplicationController
  include  Sufia::DashboardControllerBehavior
  
  # This filters out objects that you want to exclude from search results. 
  # 
  # Currently Filtering out:
  #   * ImportedMetadata 
  #
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters
  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-#{ActiveFedora::SolrService.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:ImportedMetadata\""
  end
  
end