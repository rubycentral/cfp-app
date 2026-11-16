class RemoveOtherTitleFromSponsor < ActiveRecord::Migration[6.1]
  def change
    remove_column :sponsors, :other_title, :string
  end
end
