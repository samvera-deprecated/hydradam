# RailsAdmin config file. Generated on January 04, 2013 08:55
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  config.authorize_with :cancan
  config.attr_accessible_role { :admin }


  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Hydradam', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['Bookmark', 'ChecksumAuditLog', 'Conversation', 'DomainTerm', 'Follow', 'LocalAuthority', 'LocalAuthorityEntry', 'Message', 'Notification', 'Receipt', 'Search', 'SingleUseLink', 'SubjectLocalAuthorityEntry', 'TrackingEvent', 'User', 'VersionCommitter']

  # Include specific models (exclude the others):
  config.included_models = ['User', 'ChecksumAuditLog']
  #config.included_models = ['User', 'ChecksumAuditLog', 'DomainTerm', 'LocalAuthority','LocalAuthorityEntry', 'SubjectLocalAuthorityEntry', 'TrackingEvent']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block
  
  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.


  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:





  ###  ChecksumAuditLog  ###

  config.model 'ChecksumAuditLog' do
  #   # Cross-section configuration:
  
  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  
  #   # Section specific configuration:
  
  
      list do
        field :pid
        field :dsid
        field :version
        field :pass
        field :created_at
        filters [:pass]  # Array of field names which filters should be shown by default in the table header
        # items_per_page 100    # Override default_items_per_page
        sort_by :created_at           # Sort column (default is primary key)
      end
  end


  config.model 'User' do
      list do
        field :email
        field :guest
        field :admin
        field :directory
        #filters [:email, :guest]  # Array of field names which filters should be shown by default in the table header
        # items_per_page 100    # Override default_items_per_page
        sort_by :email           # Sort column (default is primary key)
      end
      edit do
        field :email
        field :admin
        field :password
        field :password_confirmation
        field :directory
      end
  end
end
