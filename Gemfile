source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'sqlite3'


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
#gem 'sufia', path: '../sufia'
gem 'sufia', github: 'curationexperts/sufia', ref: '92c3faf'
gem 'hydra-head', github: 'projecthydra/hydra-head', branch: '6.x'
gem 'active-fedora', github: 'projecthydra/active_fedora', branch: '6.x'
gem 'solrizer', github: 'projecthydra/solrizer', branch: 'solrizer-3'
#gem 'active-fedora', path: '../active_fedora'
#gem 'solrizer', path: '../solrizer'

gem 'rails_admin'

group :development, :test do
  gem 'jettywrapper'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "devise"
gem "devise-guests", "~> 0.3"
gem "bootstrap-sass"
