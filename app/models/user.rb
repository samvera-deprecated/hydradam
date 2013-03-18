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
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable

  # validates :uid, :presence => true
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :uid, :email, :password, :password_confirmation, :remember_me, :as => [:default, :admin]
  attr_accessible :directory, :admin, as: :admin

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

  # Find an existing user by email or create one with a random password otherwise
  def self.find_for_ldap_oauth(access_token)
    info = access_token[:info]
    if user = User.where(:email => info[:email]).first
      user
    else # Create a user with a stub password.
#puts "Info: #{info.inspect}"
      User.create!(:uid => info[:nickname], :email => info[:email], :password => Devise.friendly_token[0,20])
    end
  end


  def valid_ldap_password?(password)
    conf = Devise.omniauth_configs[:ldap]
    adaptor = OmniAuth::LDAP::Adaptor.new conf.strategy
    credentials = adaptor.bind_as(:filter => Net::LDAP::Filter.eq(adaptor.uid, uid),:size => 1, :password => password)
    !!credentials
  end

end
