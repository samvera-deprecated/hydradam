require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(:default, Rails.env)
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Hydradam
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/models/datastreams #{config.root}/lib #{config.root}/lib/jobs)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Default SASS Configuration, check out https://github.com/rails/sass-rails for details
    config.assets.compress = !Rails.env.development?


    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Base directory for ftp anonymous download
    config.ftp_download_base = '/opt/ftp'

    # Threshold for ftp download
    config.ftp_download_threshold = 200000000000 

    # Base directory for original content storage 
    config.external_store_base = '/opt/storage'

    # Module for storage manager 
    #   NullStorageManager          for plain filesystem
    #   OfflineStorageManager       always indicates the file is offline
    #   ConfigurableStorageManager  checks config/offline_files.txt for files to be reported as offline 
    #   SamfsStorageManager         for Oracle SAM-QFS
    config.storage_manager = 'NullStorageManager'

    config.action_mailer.default_url_options = {host: 'wgbh.curationexperts.com'}
  end
end

ActionMailer::Base.smtp_settings = {
  :user_name => "sendgridusername",
  :password => "sendgridpassword",
  :domain => "yourdomain.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

