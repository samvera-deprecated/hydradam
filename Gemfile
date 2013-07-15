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


gem 'sufia', github: 'projecthydra/sufia', ref: '94bd48f' #'~> 2.1.0'
#gem 'sufia', path: '../sufia'
#gem 'hydra-pbcore', github:'curationexperts/hydra-pbcore', branch: 'devel'
#gem 'hydra-pbcore', :path=>'../hydra-pbcore'
gem 'rdf', github: 'ruby-rdf/rdf', ref: '9b20f6d' # Keep until rdf 1.0.8 (or 1.1.0) is released
gem 'hydra-pbcore', '2.2.0rc1'
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

gem 'em-ftpd', github: 'curationexperts/em-ftpd', branch: 'devel'
