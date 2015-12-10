class AddAccountNameToService < ActiveRecord::Migration
  def change
    add_column :services, :account_name, :string
  end
end
