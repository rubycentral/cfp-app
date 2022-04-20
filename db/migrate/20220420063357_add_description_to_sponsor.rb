class AddDescriptionToSponsor < ActiveRecord::Migration[6.1]
  def change
    add_column :sponsors, :description, :text
  end
end
