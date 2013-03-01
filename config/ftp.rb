require File.expand_path('../lib/ftp/driver', __FILE__)
opts = Hash[*ARGV[1..-1]]

driver    Ftp::Driver
user      'ftp'
group     'ftp'
port      opts['-p'] || 21 
# configure the server
#driver_args 1, 2, 3
#daemonise false
#name      "fakeftp"
#pid_file  "/var/run/fakeftp.pid"
