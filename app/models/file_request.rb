class FileRequest < ActiveRecord::Base
  belongs_to :user
  attr_accessible :file
end
