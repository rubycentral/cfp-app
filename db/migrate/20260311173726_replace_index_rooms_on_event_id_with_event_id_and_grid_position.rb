class ReplaceIndexRoomsOnEventIdWithEventIdAndGridPosition < ActiveRecord::Migration[8.1]
  def change
    remove_index :rooms, :event_id
    add_index :rooms, [:event_id, :grid_position]
  end
end
