source 'https://rubygems.org'

gem 'rails', '4.0.0'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.3.0'
end

gem 'jquery-rails'


gem 'sufia', '~> 3.4.0.rc3'
gem 'hydra-pbcore', github:'curationexperts/hydra-pbcore', ref: '99e1454'
gem 'active-fedora', '~> 6.6.1'
gem 'hydra-file_characterization', github: 'projecthydra/hydra-file_characterization', ref: '645c113' # need a 0.3.0 release
#gem 'hydra-pbcore', '3.0.4'
gem 'rails_admin', "~> 0.5.0"

group :development, :test do
  #gem 'byebug' # This is a debugger, can be removed when not needed by the developer
  gem 'jettywrapper'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'sqlite3'
  gem "unicorn"
end

group :production do
  gem 'mysql2'
end

gem "devise"
gem "bootstrap-sass"

gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'
