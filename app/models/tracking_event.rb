class TrackingEvent < ActiveRecord::Base
  belongs_to :user
  attr_accessible :event, :pid, :user

  validates :event, inclusion: %w(view download)
  validates :pid, presence: true
end
