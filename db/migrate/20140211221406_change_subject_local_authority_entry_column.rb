class ChangeSubjectLocalAuthorityEntryColumn < ActiveRecord::Migration
  def change
    change_table :subject_local_authority_entries do |t|
      t.rename :url, :uri
    end
  end
end
