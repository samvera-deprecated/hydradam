module SamfsStorageManager

# Do we have to manually release the file? `release testfile` or is it able to 
# do it automatically if it's running out of online storage?

  # Is this file ready to be used by the application?
  # @param [String] filename the name of the file
  # @return [Boolean] true if the file is staged for use
  def self.live?(filename)
    output = `sls -D #{filename}`
    raise "sls failed for #{filename}\n\t#{output}" unless $?.success?
    lines = output.split("\n")
    !lines[3].start_with?('offline')
    
  end

  # This is an asyncronous method, which may return before the file is online.
  # check live? before trying to use the file.
  # @param [String] filename the name of the file
  # @return [Boolean] true if the stage request was successful
  def self.bring_online(filename)
    system("stage #{filename}")
    $?.success?
  end
end


