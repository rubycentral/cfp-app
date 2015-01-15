class AddArchiveToEvents < ActiveRecord::Migration
  def change
    add_column :events, :archived, :boolean, :default => false
  end
end
