class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.text :log
    end
  end
end
