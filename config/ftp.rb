# Usage em-ftp config/ftp.rb <options>
# options:
#  -D                daemonize the process
#  -p <port>         operate on the specified port
#  -E <environment>  set the application environment. Default is 'development'

potential_args = *ARGV[1..-1]
opts = {}
while val = potential_args.shift
  if /\A-/.match val
    opts[val] = ''
    last = val
  elsif last
    opts[last] = val
    last = nil
  end
end
#opts = Hash[*ARGV[1..-1]]
ENV["RAILS_ENV"] ||= opts['-E'] || 'development'

require File.expand_path('../lib/ftp/driver', __FILE__)

driver    Ftp::Driver
user      'ftp'
group     'wgbh' # a group shared by the ftp user and the web app user.
port      opts['-p'] || 21 
# configure the server
#driver_args 1, 2, 3
daemonise true if opts.has_key?('-D')
name      "hydradam"
pid_file  "/run/em-ftpd.pid"
