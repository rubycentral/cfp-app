class RemoveBodyFromPages < ActiveRecord::Migration[6.1]
  def change
    remove_column :pages, :body, :text
  end
end
