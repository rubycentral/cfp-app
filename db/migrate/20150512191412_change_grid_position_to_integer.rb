class ChangeGridPositionToInteger < ActiveRecord::Migration
  def change
    remove_column :rooms, :grid_position, :string
    add_column :rooms, :grid_position, :integer
  end
end
