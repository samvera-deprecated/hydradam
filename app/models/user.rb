class User < ActiveRecord::Base
# Connects this user object to Sufia behaviors. 
 include Sufia::User
# Connects this user object to Hydra behaviors. 
 include Hydra::User
# Connects this user object to Blacklights Bookmarks. 
 include Blacklight::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :as => [:default, :admin]
  attr_accessible :directory, as: :admin

  validate :directory_must_exist

  def directory_must_exist
    unless directory.blank? || File.directory?(directory)
      errors.add(:directory, "must be an existing directory")
    end
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account. 
  def to_s
    email
  end
end
