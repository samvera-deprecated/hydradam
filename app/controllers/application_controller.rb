class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller  
  # Adds Hydra behaviors into the application controller 
  include Hydra::Controller::ControllerBehavior  
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  rescue_from CanCan::AccessDenied do 
    # used for /admin access
    redirect_to sufia.root_url, :alert => exception.message
  end

  layout 'hydra-head'

  protect_from_forgery
end
