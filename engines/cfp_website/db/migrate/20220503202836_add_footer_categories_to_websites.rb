class AddFooterCategoriesToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :footer_categories, :string, array: true
  end
end
