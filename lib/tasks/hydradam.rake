require 'rdf/ntriples'

namespace :hydradam do
  namespace :harvest do
    desc "Harvest LC subjects"
    task :lc_subjects => :environment do |cmd, args|
      vocabs = ["/tmp/subjects-skos.nt"]
      # This is a hack because sufia's subjects import doesn't work. Hopefully we can
      # remove this once sufia is updated to use the questioning_authority gem.
      if LocalAuthority.where(name: 'lc_subjects').empty?
        LocalAuthority.create(name: 'lc_subjects')
        vocabs.each do |file|
          RDF::Reader.open(file) do |reader|
            batch = []
            reader.each_statement do |statement|
              if statement.predicate == RDF::SKOS.prefLabel
                batch << {uri: statement.subject.to_s,
                          label: statement.object.to_s,
                          lowerLabel: statement.object.to_s.downcase}
              end
              if batch.length > 1000
                SubjectLocalAuthorityEntry.create(batch)
                batch = []
              end
            end
            SubjectLocalAuthorityEntry.create(batch) if batch.length > 0
          end
        end
      end
    end

    desc "Harvest Lexvo languages"
    task :lexvo_languages => :environment do |cmd, args|
      vocabs = ["/tmp/lexvo_2012-03-04.rdf"]
      LocalAuthority.harvest_rdf(cmd.to_s.split(":").last, vocabs,
                                 :format => 'rdfxml',
                                 :predicate => RDF::URI("http://www.w3.org/2008/05/skos#prefLabel"))
    end
  end

  desc "default_config"
  task :default_config do

    filenames = [
      "config/database.yml.example",
      "config/redis.yml.example",
      "config/initializers/secret_token.rb.example",
      "config/initializers/devise.rb.example"
    ]
    
    filenames.each do |filename|
      app_root = File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))
      new_filename = filename.sub(/\.example$/, '')
      begin
        puts "Copying #{filename} to #{new_filename}"
        FileUtils.cp(File.join(app_root, filename), File.join(app_root, new_filename))
      rescue => e
        puts e.message
      end
    end
  end
end
