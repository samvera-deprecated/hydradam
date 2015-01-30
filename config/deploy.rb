require 'bundler/capistrano'

###############################################################################
# MULTISTAGE CONFIG - Set configuration for multi-stage deployment.
#  See config/deploy/[stage].rb for stage-specific settings. 
###############################################################################

set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'


###############################################################################
# LOAD OTHER RECIPES
###############################################################################
load 'config/deploy/recipes/upload'


###############################################################################
# COMMON CONFIG - Set configuration common to all stages and tasks
#   Config for specific stages should be set in config/deploy/name_of_stage.rb
###############################################################################

# General info
server 'lshydra01.wgbh.org', :app, :web, :db, primary: true
set :application, "HydraDAM"
set :user, "hydradam"
set :group, "hydradam"
set :use_sudo, false
set :rails_env, "production"
set :keep_releases, 5

# Github
set :scm, :git
set :repository,  "https://github.com/WGBH/hydradam.git"
set :scm_username , "WGBH"
set :deploy_via, :remote_cache
set :branch, fetch(:branch, "master")

# SSH
default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }


###############################################################################
# HOOKS - Set up all the hooks to say what happens and when
###############################################################################
# before "deploy:setup", "upload_shared:database_yml"

before 'deploy:assets:precompile', 'deploy:migrate'
before 'deploy:migrate', 'link_shared:database_yml'

# Symlink all other shared stuffs
after 'deploy:update_code', 'link_shared:application_yml'
after 'deploy:update_code', 'link_shared:uploads'
after 'deploy:upate_code', 'link_shared:blog'
after 'deploy:update_code', 'link_shared:jetty'
after 'deploy:update_code', 'link_shared:log'
after 'deploy:update_code', 'link_shared:static_content'



after 'deploy:update', 'deploy:cleanup'

###############################################################################
# TASKS - Define all tasks for setup, deployment, etc.
###############################################################################


# Deployment Tasks
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc 'Show deployed revision'
  task :revision, :roles => :app do
    run "cat #{current_path}/REVISION"
  end
end

namespace :link_shared do

  desc "Link to shared database config in latest release"
  task :database_yml do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  desc "Link to shared application config in latest release"
  task :application_yml do
    run "ln -nfs #{shared_path}/config/application.yml #{latest_release}/config/application.yml"
  end

  desc "Link to shared blog in latest release"
  task :blog do
    run "ln -nfs #{shared_path}/public/blog #{latest_release}/public/blog"
  end

  desc "Link to shared jetty instance in latest release"
  task :jetty do
    run "ln -nfs #{shared_path}/jetty #{latest_release}/jetty"
  end

  desc "Link to shared log in latest release"
  task :uploads do
    run "ln -nfs #{shared_path}/public/uploads #{latest_release}/public/uploads"
  end

  desc "Link to shared log in latest release"
  task :log do
    run "ln -nfs #{shared_path}/log #{latest_release}/log"
  end

  desc "Link to shared static content under public directory"
  task :static_content do
    run "ln -nfs #{shared_path}/public/mpot #{latest_release}/public/mpot"
    run "ln -nfs #{shared_path}/public/pdf #{latest_release}/public/pdf"
    run "ln -nfs #{shared_path}/public/logos #{latest_release}/public/logos"
    run "ln -nfs #{shared_path}/public/sfdb #{latest_release}/public/sfdb"
    run "ln -nfs #{shared_path}/public/img #{latest_release}/public/img"
  end
end