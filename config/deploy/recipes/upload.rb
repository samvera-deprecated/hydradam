require 'byebug'

namespace :deploy do
  task :upload do

    opts = {
      from: ENV['from'] || './',
      files: ENV['files'] || '**/*',
      dest: ENV['dest'] || nil
    }

    file_list = Dir.glob(File.join(opts[:from], opts[:files])).select{|f| File.file? f }

    # Check parameters
    raise "No such directory \"#{opts[:from]}\". The \"from\" argument must be a directory." unless File.directory? opts[:from]
    raise "No files match pattern \"#{opts[:files]}\" in directory \"#{opts[:from]}\"" if file_list.empty?

    # here are some capistrano methods that return remote paths.
    capistrano_methods = [:current_path, :current_release, :latest_release, :previous_release, :release_path, :releases_path, :shared_path]
    raise "No destination specified. Use dest=path/to/remote/dir OR dest=capistrano_var where capistrano_var is one of :#{capistrano_methods.join(', :')}" unless opts[:dest]

    # Figure out what the actual destination directory is
    if (opts[:dest] =~ /^:/)
      # If dest begins with a colon, convert it to a symbol, and see if it's one of the special capistrano variables.
      opts[:dest] = opts[:dest].sub(/^:/, '').to_sym
      raise "Unknown capistrano variable '#{opts[:dest]}'. Use one of :#{capistrano_methods.join(', :')}" unless capistrano_methods.include? opts[:dest]
      dest_dir = send(opts[:dest])
    else
      # IF dest does not begin with a colon, treat as a literal path.
      dest_dir = dest
    end

    # print out the list of files, and prompt use for a Yes/No response on the upload
    puts "File(s)...\n#{file_list.join("\n")}\n"
    answer = ''
    while !%w(y yes n no).include?(answer)
      puts "Type 'y' or 'n'" unless answer == ''
      set :answer, Capistrano::CLI.ui.ask("Upload #{file_list.count} file(s) to #{dest_dir} ? (y/N)")
      answer = fetch(:answer).downcase

      # if the user just hit Enter without typing anything, assume "no" is the answer
      answer = 'n' if answer == ''
    end

    if answer == 'y'
      file_list.each do |file|

        # preserve the dir structure on remote server by removing opts[:from] from the file path,
        # but keeping the rest, then doing a `mkdir -p` on the remote server.
        remote_relative_path = File.expand_path(file).sub(File.expand_path(opts[:from]), '')
        remote_path = File.join(dest_dir, remote_relative_path)
        run "mkdir -p #{File.dirname(remote_path)}"

        # `top` required here b/c we are calling #upload inside of :deploy namespace. It's a Capistrano thing.
        top.upload(file, remote_path, via: :scp)
      end
    else
      puts "Cancelling upload."
    end
  end
end