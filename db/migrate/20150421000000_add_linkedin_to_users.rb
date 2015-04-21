class AddLinkedinToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :linkedin_handle, :string
  end

  def self.down
    remove_column :users, :linkedin_handle, :string
  end
end