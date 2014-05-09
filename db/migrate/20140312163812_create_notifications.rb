class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :person, index: true
      t.string :message
      t.timestamp :read_at
      t.string :target_path

      t.timestamps
    end
  end
end
