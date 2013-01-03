class CreateTrackingEvents < ActiveRecord::Migration
  def change
    create_table :tracking_events do |t|
      t.string :pid
      t.references :user
      t.string :event

      t.timestamps
    end
    add_index :tracking_events, :user_id
    add_index :tracking_events, [:pid, :event]
    add_index :tracking_events, :pid
  end
end
