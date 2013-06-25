module WGBH
  class FileCreator
    attr_accessor :file_list
    attr_writer :directory

    def initialize
    end

    def directory
      @directory ||= '/opt/ftp/'
    end

    def file_list 
      Dir.glob("#{directory}/**/*")
    end

    def instantiate_files
      file_list.each do |file_name|
        GenericFile.new.tap do |file|
          file.relative_path = file_name
          puts "Set FN to #{file.relative_path}"
          file.save(validate:false)
        end
      end
    end
  end
end
