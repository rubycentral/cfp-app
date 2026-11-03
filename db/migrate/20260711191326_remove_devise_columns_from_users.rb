class RemoveDeviseColumnsFromUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :encrypted_password, :password_digest

    remove_column :users, :sign_in_count, :integer, default: 0, null: false
    remove_column :users, :current_sign_in_at, :datetime
    remove_column :users, :current_sign_in_ip, :inet
    remove_column :users, :last_sign_in_at, :datetime
    remove_column :users, :last_sign_in_ip, :inet
    remove_column :users, :remember_created_at, :datetime

    # Stateless generates_token_for tokens replaced both stored-token schemes
    remove_column :users, :confirmation_token, :string
    remove_column :users, :confirmation_sent_at, :datetime
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
  end
end
