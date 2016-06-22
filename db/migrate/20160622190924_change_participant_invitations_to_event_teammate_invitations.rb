class ChangeParticipantInvitationsToEventTeammateInvitations < ActiveRecord::Migration
  def change
    rename_table :participant_invitations, :event_teammate_invitations
  end
end
