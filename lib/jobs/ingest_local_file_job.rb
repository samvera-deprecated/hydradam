class IngestLocalFileJob
  def queue_name
    :ingest
  end

  attr_accessor :directory, :filename, :user_key, :generic_file_id

  def initialize(generic_file_id, directory, filename, user_key)
    self.generic_file_id = generic_file_id
    self.directory = directory
    self.filename = filename 
    self.user_key = user_key
  end

  def run
    generic_file = GenericFile.find(generic_file_id)
    user = User.find_by_user_key(user_key)
    raise "Unable to find user for #{user_key}" unless user
    file = File.open(File.join(directory, filename), 'rb')
    #TODO virus check?
    Sufia::GenericFile::Actions.create_content(generic_file, file, filename, 'content', user)
    Sufia.queue.push(ContentDepositEventJob.new(generic_file.pid, user_key))
  end
end
