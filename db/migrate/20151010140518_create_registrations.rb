class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :pass_id, null: false
      t.integer :device_id, null: false
    end
  end
end
