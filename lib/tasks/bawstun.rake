# namespace :ci do
#   desc "Prepare to run specs via continuous integration"
#   task :prepare => ["jetty:clean", "jetty:config"]
# end

desc "Run ci"
task :ci do

  # Download a clean copy of Jetty, preloaded with Solr and Fedora from the hydra-jetty gem.
  Rake::Task['jetty:clean'].invoke

  # Copy config from solr_conf/ and fedora_conf/ directories to Solr and Fedora downloaded from hydra-jetty gem.
  Rake::Task['jetty:config'].invoke
  
  require 'jettywrapper'
  jetty_params = Jettywrapper.load_config.merge({:jetty_home => File.join(Rails.root , 'jetty'), :startup_wait=>5 })
  
  puts "Starting Jetty"
  error = nil
  error = Jettywrapper.wrap(jetty_params) do
      until `curl localhost:8983/fedora-test/describe`.include? "Repository Information View" do
        puts "waiting . . ."  
        sleep 10
      end
      Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end