class AddHeaderFooterFlagsToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :hide_header, :boolean, default: false, null: false
    add_column :pages, :hide_footer, :boolean, default: false, null: false
  end
end
