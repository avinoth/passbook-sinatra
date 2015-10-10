class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :identifier, null: false
      t.string :push_token, null: false
    end
  end
end
