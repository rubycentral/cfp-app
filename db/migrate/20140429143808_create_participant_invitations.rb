class CreateParticipantInvitations < ActiveRecord::Migration
  def change
    create_table :participant_invitations do |t|
      t.string :email
      t.string :state
      t.string :slug
      t.string :role
      t.string :token
      t.belongs_to :event

      t.timestamps
    end
  end
end
