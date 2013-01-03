class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  def views
    TrackingEvent.where(pid: pid)
  end
end
