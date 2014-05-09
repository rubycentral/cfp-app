class ParticipantInvitationMailer < ActionMailer::Base
  def create(participant_invitation)
    @participant_invitation = participant_invitation
    @event = participant_invitation.event

    mail to: participant_invitation.email,
      subject: "You've been invited to participate in a CFP"
  end
end
