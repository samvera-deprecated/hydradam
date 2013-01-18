class IngestLocalFileJob
  def queue_name
    :ingest
  end

  attr_accessor :directory, :filename, :user_key, :batch_id

  def initialize(directory, filename, user_key, batch_id)
    self.directory = directory
    self.filename = filename 
    self.user_key = user_key
    self.batch_id = batch_id
  end

  def run
    user = User.find_by_user_key(user_key)
    generic_file = GenericFile.new
    file = File.open(File.join(directory, filename), 'rb')
    #TODO virus check?
    Sufia::GenericFile::Actions.create(generic_file, file, batch_id, filename, 'content', user)
    Sufia.queue.push(ContentDepositEventJob.new(generic_file.pid, user_key))
  end
end
