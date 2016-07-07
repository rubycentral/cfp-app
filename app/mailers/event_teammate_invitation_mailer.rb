class EventTeammateInvitationMailer < ApplicationMailer

  def create(event_teammate_invitation)
    @event_teammate_invitation = event_teammate_invitation
    @event = event_teammate_invitation.event

    mail_markdown to: event_teammate_invitation.email,
                  from: @event.contact_email,
                  subject: "You've been invited to participate in a CFP"
  end
end
