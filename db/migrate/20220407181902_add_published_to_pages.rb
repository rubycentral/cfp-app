class AddPublishedToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :published, :boolean, default: false
  end
end
