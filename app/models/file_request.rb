class FileRequest < ActiveRecord::Base
  belongs_to :user

  validates :pid, :uniqueness => {:scope => [:user_id, :fulfillment_date]}, :unless => :fulfillment_date
end
