source 'https://rubygems.org'

gem 'rails', '3.2.12'


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
gem 'sufia', github: 'curationexperts/sufia', ref: 'ad240ed'
#gem 'sufia', path: '../sufia'
#gem 'hydra-head', github: 'projecthydra/hydra-head', ref: '424152f'
gem 'active-fedora', github: 'projecthydra/active_fedora', ref: 'daf98ac' #need rc4
#gem 'hydra-head', '6.0.0.pre6'
gem 'hydra-head'
gem 'hydra-pbcore', github:'curationexperts/hydra-pbcore', branch: 'devel'
#gem 'hydra-pbcore', :path=>'../hydra-pbcore'

gem 'rails_admin'

group :development, :test do
  gem 'jettywrapper'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'sqlite3'
end

group :production do
  gem 'mysql2'
end

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "devise"
gem "devise-guests", "~> 0.3"
gem "bootstrap-sass"
