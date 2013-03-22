source 'https://rubygems.org'

gem 'rails', '3.2.13'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'


gem 'blacklight'
#gem 'sufia', '0.0.8'
gem 'sufia', github: 'curationexperts/sufia', ref: '24e65eb'
#gem 'sufia', path: '../sufia'
gem 'hydra-head'
#gem 'hydra-pbcore', github:'curationexperts/hydra-pbcore', branch: 'devel'
#gem 'hydra-pbcore', :path=>'../hydra-pbcore'
gem 'hydra-pbcore', '2.2.0rc1'
gem 'rails_admin', "~> 0.4.5"

group :development, :test do
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
