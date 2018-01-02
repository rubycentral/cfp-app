class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.references :event, index: true
      t.string :name
      t.string :room_number
      t.string :level
      t.string :address
      t.integer :capacity
      t.integer :grid_position

      t.timestamps null: true
    end
  end
end
