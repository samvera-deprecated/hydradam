# Setting up a local dev copy

```
git clone ...
cd bawstun
git submodule init
git submodule update
bundle install
cp config/database.yml.sample config/database.yml
cp config/fedora.yml.sample config/fedora.yml
cp config/solr.yml.sample config/solr.yml
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
