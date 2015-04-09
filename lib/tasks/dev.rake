namespace :dev do

  desc "Enable all the example config files for development (abort on failure)"
  task :default_config do
    files_to_copy = {
      "config/database.yml.sample" => "config/database.yml",
      "config/redis.yml.sample" => "config/redis.yml",
      "config/initializers/devise.rb.sample" => "config/initializers/devise.rb",
      "config/solr.yml.sample" => "config/solr.yml",
      "config/fedora.yml.sample" => "config/fedora.yml",
      "config/initializers/secret_token.rb.sample" => "config/initializers/secret_token.rb"
    }

    files_to_copy.each do |from, to|
      cmd = "cp #{from} #{to}"
      puts cmd
      result = `#{cmd} 2>&1`
      raise result unless result == ''
    end
  end

end