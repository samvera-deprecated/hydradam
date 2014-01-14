Hydradam::Application.routes.draw do

  namespace :admin do
    mount RailsAdmin::Engine => '/dashboard', :as => 'rails_admin'
  end

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)
  Hydra::BatchEdit.add_routes(self)

  devise_for :users
  
  # Metadata Templates routes (based partly on catalog routes)
  resources 'imported_metadata_manager', :only=>:index do
    collection do
      get 'page/:page', :action => :index
      get 'activity', :action => :activity, :as => :dashboard_activity
      get 'facet/:id', :action => :facet, :as => :dashboard_facet
    end
  end
  
  resources "imported_metadata_files", except:[:index] do
    member do
      post 'apply' 
    end
  end

  # This must be the very last route in the file because it has a catch all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
end
