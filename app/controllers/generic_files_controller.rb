class GenericFilesController < ApplicationController
  include Sufia::FilesControllerBehavior

  after_filter :log_visit, :only=>:show

  def log_visit
    view = @generic_file.views.create!(user: current_user, event: 'view')
  end

end
