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

  validate :directory_must_exist

  def directory_must_exist
    unless directory.blank? || File.directory?(directory)
      errors.add(:directory, "must be an existing directory")
    end
  end

  def files
    return [] unless directory.present? && File.directory?(directory)
    Dir[File.join(directory, '*')].inject([]) do |accum, val|
      accum << { name: File.basename(val), directory: File.directory?(val)}
      accum
    end
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account. 
  def to_s
    email
  end
end
