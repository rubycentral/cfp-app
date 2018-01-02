class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.string :message
      t.string :target_path
      t.timestamp :read_at

      t.timestamps null: true
    end
  end
end
