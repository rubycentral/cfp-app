class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :proposal, index: true
      t.references :user, index: true
      t.string :email
      t.string :state, default: 'pending'
      t.string :slug
      t.timestamps
    end

    add_index :invitations, [:proposal_id, :email], unique: true
    add_index :invitations, :slug, unique: true
  end
end
