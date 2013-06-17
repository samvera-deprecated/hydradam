# Setting up a local dev copy

```
git clone ...
cd bawstun
cp config/database.yml.sample config/database.yml   # setup local config files with dev environment defaults
cp config/redis.yml.sample config/redis.yml
cp config/solr.yml.sample config/solr.yml
cp config/fedora.yml.sample config/fedora.yml
bundle install
```
**Note:* You will want to edit `config/solr.yml`, `config/fedora.yml` to include urls for your production Fedora and Solr

It's easiest to use hydra-jetty to get fedora and solr running in your development environment, get a copy from github and update your application config files:
```
rake jetty:unzip
rake jetty:config
```

Make sure your database configuration is up-to-date:
```
rake db:migrate
```

Set up your secret token.
```
cp config/initializers/secret_token.rb.sample config/initializers/secret_token.rb
```
... then replace the sample secret token in that file with one of your own. You can use `rake secret` to generate a token for you.
 
You also need ffmpeg installed with some extra codecs enabled.  See the [Sufia README file](https://github.com/projecthydra/sufia/blob/master/README.md#if-you-want-to-enable-transcoding-of-video-instal-ffmpeg-version-10) for instructions.

## Start workers
```
QUEUE=* rake environment resque:work
```

# Running tests


If you have jetty running, run 

```
rake spec
```

To run the whole test suite, including spinning jetty up & down, loading fedora fixtures, etc. 
```
rake ci
```

# Running the ftp server

```
sudo em-ftpd config/ftp.rb
```
