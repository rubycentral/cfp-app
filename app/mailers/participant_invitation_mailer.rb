class ParticipantInvitationMailer < ApplicationMailer

  def create(participant_invitation)
    @participant_invitation = participant_invitation
    @event = participant_invitation.event

    mail_markdown to: participant_invitation.email,
                  from: @event.contact_email,
                  subject: "You've been invited to participate in a CFP"
  end
end

