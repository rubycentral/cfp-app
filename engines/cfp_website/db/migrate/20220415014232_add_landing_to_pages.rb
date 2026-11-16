class AddLandingToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :landing, :boolean, default: false, null: false
  end
end
