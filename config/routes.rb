Bawstun::Application.routes.draw do

  namespace :admin do
    mount RailsAdmin::Engine => '/dashboard', :as => 'rails_admin'
  end

  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)
  Hydra::BatchEdit.add_routes(self)


  devise_for :users
  mount Sufia::Engine => '/'

end
