module Organizer::EventTeammateInvitationsHelper
  def new_event_teammate_invitation_button
    link_to 'Invite new event teammate', '#', class: 'btn btn-primary',
      data: { toggle: 'modal', target: "#new-event-teammate-invitation" },
      id: 'invite-new-event-teammate'
  end
end
