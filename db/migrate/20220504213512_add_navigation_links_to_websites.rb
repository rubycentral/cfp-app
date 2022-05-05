class AddNavigationLinksToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :navigation_links, :string, array: true, default: []
    change_column :websites, :footer_categories, :string, array: true, default: []
    remove_column :pages, :hide_navigation, :boolean, default: false, null: false
  end
end
