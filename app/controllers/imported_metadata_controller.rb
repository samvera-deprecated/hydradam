# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'blacklight/catalog'
class ImportedMetadataController < ApplicationController
  include  Sufia::DashboardControllerBehavior
  
  self.copy_blacklight_config_from(CatalogController)
  
  configure_blacklight do |config|
    config.add_facet_field "is_part_of_ssim", :label => "Parents", :limit => 5
  end
  
  # This filters out objects that you want to exclude from search results. 
  # 
  # Currently Filtering out:
  #   * ImportedMetadata 
  #
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters
  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-#{ActiveFedora::SolrService.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:GenericFile\""
  end
  
end
