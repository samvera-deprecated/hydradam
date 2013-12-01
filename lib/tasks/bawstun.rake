desc "Run ci"
task :ci do 
  puts "Updating Solr config"
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