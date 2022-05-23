class AddBodyPublishedAtToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :body_published_at, :datetime, default: nil
  end
end
