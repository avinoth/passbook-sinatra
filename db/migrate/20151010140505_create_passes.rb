class CreatePasses < ActiveRecord::Migration
  def change
    create_table :passes do |t|
      t.string :serial_number, null: false
      t.jsonb :data, null: false
      t.integer :version, default: 1
    end
  end
end
