module OfflineStorageManager
  # Is this file ready to be used by the application
  def self.live?(filename)
    false
  end

  # this is an asyncronous method, which may return before the file is online.
  # check live? before serving it up.
  def self.bring_online(filename)
    true
  end
end
