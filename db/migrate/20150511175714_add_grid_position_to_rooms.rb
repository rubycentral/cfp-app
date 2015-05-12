class AddGridPositionToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :grid_position, :string
  end
end
