class AddAccountNameToIdentities < ActiveRecord::Migration[8.1]
  def change
    add_column :identities, :account_name, :string
  end
end
