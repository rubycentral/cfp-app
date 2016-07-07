module Staff::TeamInvitationsHelper
  def new_team_invitation_button
    link_to 'Invite new event teammate', '#', class: 'btn btn-primary btn-sm',
      data: { toggle: 'modal', target: "#new-event-teammate-invitation" },
      id: 'invite-new-event-teammate'
  end
end
