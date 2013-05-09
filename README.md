# Setting up a local dev copy

```
git clone ...
cd bawstun
cp config/database.yml.sample config/database.yml   # setup local config files with dev environment defaults
cp config/redis.yml.sample config/redis.yml
bundle install
```

It's easiest to use hydra-jetty to get fedora and solr running in your development environment, get a copy from github and update your application config files:
```
rake jetty:unzip
rake jetty:config
```

Make sure your database configuration is up-to-date:
```
rake db:migrate
```

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
