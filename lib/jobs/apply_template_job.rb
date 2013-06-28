class ApplyTemplateJob
  def queue_name
    :templates
  end

  attr_accessor :user_key, :generic_file_id, :attributes

  def initialize(user_key, generic_file_id, attributes)
    self.user_key = user_key
    self.generic_file_id = generic_file_id
    self.attributes = attributes
  end

  def run
    generic_file = GenericFile.find(generic_file_id)
    user = User.find_by_user_key(user_key)
    raise "Unable to find user for #{user_key}" unless user

    generic_file.attributes = attributes
    generic_file.record_version_committer(user)
    generic_file.save!

    Sufia.queue.push(ContentDepositEventJob.new(generic_file.pid, user_key))
  end
end

