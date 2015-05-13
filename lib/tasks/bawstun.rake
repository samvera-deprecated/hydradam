desc "Run ci"
task :ci do

  Rake::Task['hydradam:default_config'].invoke

  # Install fits
  Rake::Task['fits:install'].invoke

  require 'jettywrapper'
  Jettywrapper.hydra_jetty_version = 'v7.0.0'
  Jettywrapper.clean


  # Download a clean copy of Jetty, preloaded with Solr and Fedora from the hydra-jetty gem.
  # Rake::Task['jetty:clean'].invoke

  # Copy config from solr_conf/ and fedora_conf/ directories to Solr and Fedora downloaded from hydra-jetty gem.
  Rake::Task['jetty:config'].invoke
  
  jetty_params = Jettywrapper.load_config.merge({:jetty_home => File.join(Rails.root , 'jetty'), :startup_wait=> 180 })
  
  puts "Starting Jetty"
  error = nil
  error = Jettywrapper.wrap(jetty_params) do
      Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end