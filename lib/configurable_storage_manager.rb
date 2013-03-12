module ConfigurableStorageManager
  CONFIG_FILE = File.join(Rails.root, 'config', 'offline_files.txt')
  # Is this file ready to be used by the application
  def self.live?(filename)
    return false unless File.exists?(filename)
    if File.exists?(CONFIG_FILE)
      lines = File.readlines(CONFIG_FILE)
      !lines.reject{ |l| /^\s*#/.match l }.include?(filename)
    else
      true
    end
  end

  # this is an asyncronous method, which may return before the file is online.
  # check live? before serving it up.
  def self.bring_online(filename)
    true
  end
end

