class FileRequest < ActiveRecord::Base
  belongs_to :user
  attr_accessible :pid, :user, :fulfillment_date

  validates :pid, :uniqueness => {:scope => [:user_id, :fulfillment_date]}, :unless => :fulfillment_date
end
