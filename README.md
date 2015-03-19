[![Build Status](https://travis-ci.org/projecthydra-labs/hydradam.svg?branch=HDM-37-set-up-Travis-CI-for-github-repo)](https://travis-ci.org/projecthydra-labs/hydradam)

# Setting up a local development copy

```
git clone ...
cd hydradam
cp config/database.yml.sample config/database.yml   # setup local config files with dev environment defaults
cp config/redis.yml.sample config/redis.yml
cp config/solr.yml.sample config/solr.yml
cp config/fedora.yml.sample config/fedora.yml
bundle install
```
It's easiest to use hydra-jetty to get fedora and solr running in your development environment.
Get a copy from github and update your application config files:

```
rake jetty:unzip
rake jetty:config
```

Set up your secret tokens.
```
cp config/initializers/secret_token.rb.sample config/initializers/secret_token.rb
cp config/initializers/devise.rb.sample config/initializers/devise.rb
```
For production environments you will want to replace the default values.
You can use `rake secret` to generate a token for you.
 

Make sure your database configuration is up-to-date:
```
rake db:migrate
```

You also need ffmpeg installed with some extra codecs enabled.  See the [Sufia README file](https://github.com/projecthydra/sufia/blob/master/README.md#if-you-want-to-enable-transcoding-of-video-instal-ffmpeg-version-10) for instructions.

## Import Authority files

(These vocabularies are not actually necessary for most development tests, and the LCSH file is big.) 

### Subjects

Go to http://id.loc.gov/download/ and find the "LC Subject Headings (SKOS/RDF only)" file.
Download the .nt version of that file.
Uncompress the file and move it to ```/tmp/subjects-skos.nt```.

Run the rake task to import it:
```bash
rake hydradam:harvest:lc_subjects
```

### Languages

Download and unzip this file: http://www.lexvo.org/resources/lexvo_2012-03-04.rdf.gz
Move the file to ```/tmp/lexvo_2012-03-04.rdf```

Run the rake task to import it:
```bash
rake hydradam:harvest:lexvo_languages
```

## Redis

Installation and startup will depend on your environment. For a Mac with Homebrew:

```
brew install redis
sudo redis-server /usr/local/etc/redis.conf
QUEUE=* rake environment resque:work
```

# Running tests

```
rake jetty:start # If it's not running already.
rake spec
```

To run the whole test suite, including spinning jetty up & down, loading fedora fixtures, etc. 
```
rake ci
```

=======
## Importing metadata templates

```bash
# Usage:
./script/import_metadata <file> <user_id>
  
# Example:
./script/import_metadata spec/fixtures/import/metadata/broadway_or_bust.pbcore.xml archivist1@example.com
```
