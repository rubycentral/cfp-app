class ConvertWebsiteContentsToPolymorphic < ActiveRecord::Migration[6.1]
  def change
    change_table :website_contents, bulk: true do |t|
      t.rename :website_id, :contentable_id
      t.string :contentable_type, default: 'Website', null: false
      t.index [:contentable_id, :contentable_type]
      t.remove_index :contentable_id
    end
  end
end
