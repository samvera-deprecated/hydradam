source 'https://rubygems.org'

gem 'rails', '4.0.3'


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


#gem 'sufia', '~> 3.5.0'
gem 'sufia', '4.0.0'
 
# This is needed when Sufia version is < 4
gem 'mini_magick', '< 4' if RUBY_VERSION < '2.1.0'

gem 'hydra-pbcore', '3.3.1'
gem 'rails_admin'

group :development, :test do
  #gem 'byebug' # This is a debugger, can be removed when not needed by the developer
  gem 'pry'
  gem 'pry-byebug'
  gem 'jettywrapper'
  gem 'rspec-rails', '~> 3.0'
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
gem 'rspec-its'