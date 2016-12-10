class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.references :event, index: true
      t.references :user, index: true
      t.string :role
      t.boolean :notifications, default: true
      t.timestamps
    end
  end
end
