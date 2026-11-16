class AddHidingFieldsToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :hide_page, :boolean, default: false, null: false
    add_column :pages, :hide_navigation, :boolean, default: false, null: false
  end
end
