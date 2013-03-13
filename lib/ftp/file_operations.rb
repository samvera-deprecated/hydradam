module Ftp
  class FileOperations
    # Upload a new file to FTP server
    # @param [String] path Absolute path to final location of the file
    # @param [String] tmp_path Absolute path to temporary file created by server
    # @yield [Fixnum] New uploaded file size or false if there were an error
    def self.put_file(path, tmp_path )
      FileUtils.copy( tmp_path, path )
      File.size( tmp_path )
    end

    def self.get_file(path)
      File.open path
    end
  end
end

