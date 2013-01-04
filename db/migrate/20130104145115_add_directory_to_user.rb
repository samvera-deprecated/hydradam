class AddDirectoryToUser < ActiveRecord::Migration
  def change
    add_column :users, :directory, :string
  end
end
