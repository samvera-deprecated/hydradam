class CreateFileRequests < ActiveRecord::Migration
  def change
    create_table :file_requests do |t|
      t.string :pid
      t.references :user
      t.datetime :fulfillment_date

      t.timestamps
    end
    add_index :file_requests, :user_id
    add_index :file_requests, :pid
  end
end
