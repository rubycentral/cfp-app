class AddThemeToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :theme, :string, default: Website::DEFAULT, null: false
  end
end
