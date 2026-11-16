class AddCachingFieldsToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :caching, :string, default: 'off', null: false
    add_column :websites, :purged_at, :datetime
  end
end
