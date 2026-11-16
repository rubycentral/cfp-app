class AddFooterCategoryToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :footer_category, :string
  end
end
