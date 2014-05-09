class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :room_number
      t.string :level
      t.string :address
      t.integer :capacity
      t.references :event, index: true

      t.timestamps
    end
  end
end
