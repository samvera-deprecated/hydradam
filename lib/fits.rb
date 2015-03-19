module Fits
  class Installer
    attr_accessor :download_url, :install_dir, :symlink, :verbose

    def initialize(opts={})
      @download_url = opts.delete(:download_url) || 'http://projects.iq.harvard.edu/files/fits/files/fits-0.8.4_0.zip'
      @install_dir = opts.delete(:install_dir) || Dir.pwd
      @symlink = opts.delete(:symlink) || 'fits'
      @verbose = opts.delete(:verbose) || true
      @orig_dir = Dir.pwd
    end


    def install
      remove_all!
      download
      unzip
      make_executable
      make_symlink
      remove_zip_file
      Dir.chdir(@orig_dir)
    end

    def remove_fits!
      puts_around("Removing #{unzipped_dir}") { FileUtils.rm_r(unzipped_dir, secure: true) if Dir.exists? unzipped_dir }
    end

    def remove_zip_file
      Dir.chdir(install_dir) do
        puts_around("Removing #{File.expand_path(zipped_filename)}") { FileUtils.rm_r(zipped_filename, secure: true) if File.exists? zipped_filename }
      end
    end

    def remove_all!
      remove_zip_file
      remove_fits!
    end

    private

    def zipped_filename
      File.basename(download_url)
    end

    # Returns a best guess at what the unzipped directory is.
    # NOTE: This is entirely dependent on who is providing the download link.
    #   In this case, it's Harvard, and the format of the unzipped dir is, e.g. 'fits-0.8.4'.
    def unzipped_dir
      File.join(install_dir, zipped_filename.sub(/_\d+\.zip$/, ''))
    end

    def download
      Dir.chdir(install_dir)
      run "curl -O #{download_url}"
    end

    def unzip
      Dir.chdir(install_dir)
      run "unzip #{zipped_filename}"
    end

    def make_executable
      Dir.chdir(unzipped_dir)
      run "chmod a+x #{script_name}"
    end

    def script_name
      'fits.sh'
    end

    def make_symlink
      Dir.chdir(unzipped_dir)
      run "ln -s #{script_name} #{symlink}"
    end

    # Helper command for better output.
    def run(cmd)
      if verbose
        puts_around("Executing: #{cmd}") { %x( #{cmd} ) }
      else
        %x( #{cmd} )
      end
    end

    # Helper method for better ouput.
    def puts_around(before=nil, after=nil)
      puts before unless before.nil?
      result = yield if block_given?
      puts after unless after.nil?
      result
    end
  end
end