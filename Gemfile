source 'https://rubygems.org'

gem 'rails', '~> 4.1.0'


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

# These gems specified in Sufia upgrade guide:
# https://github.com/projecthydra/sufia/releases
gem 'sufia', ' ~> 6.0.0'
gem 'rsolr', '~> 1.0.6'
gem 'jbuilder', '~> 2.0'
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'

gem 'hydra-pbcore', '3.3.1'


# gem 'rails_admin'

# We needed to fork rails_admin because it has a dependency on kaminari that
# was conflicting with the jcoyne/kaminari, 'sufia' branch, specified abvoe.
# The forked rails_admin relaxes the kaminari requirement to allow it to use
# jcoyne/kaminari. All of this can go back to normal once jcoyne's PR is
# merged: https://github.com/amatsuda/kaminari/pull/636
gem 'rails_admin', github: 'WGBH/rails_admin', branch: 'v0.6.7-jcoyne-kaminari'


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

# gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'
gem 'rspec-its'
