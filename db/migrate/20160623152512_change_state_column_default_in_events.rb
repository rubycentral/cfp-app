class ChangeStateColumnDefaultInEvents < ActiveRecord::Migration
  def change
    change_column_default :events, :state, 'draft'
  end
end
