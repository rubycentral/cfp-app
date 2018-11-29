class CreateNonUniqueUserIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :email
    remove_index :users, :reset_password_token
    remove_index :users, :confirmation_token
    remove_index :users, :uid

    add_index :users, :email
    add_index :users, :reset_password_token
    add_index :users, :confirmation_token
    add_index :users, :uid
  end
end
