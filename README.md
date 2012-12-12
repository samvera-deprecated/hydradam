# Setting up a local dev copy

```
git clone ...
git submodule init
git submodule update
bundle install
rake db:migrate
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

