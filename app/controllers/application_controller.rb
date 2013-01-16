class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller  
  # Adds Hydra behaviors into the application controller 
  include Hydra::Controller::ControllerBehavior  
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  rescue_from ActionController::RoutingError, :with => :render_404


  layout 'hydra-head'

  protect_from_forgery
end
