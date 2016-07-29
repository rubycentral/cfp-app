class SpeakerInvitationMailer < ApplicationMailer

  def create(invitation, speaker)
    @invitation = invitation
    @proposal   = invitation.proposal
    @speaker    = speaker

    mail_markdown to: @invitation.email,
                  from: @proposal.event.contact_email,
                  subject: "You've been invited to join the \"#{@proposal.title}\" proposal for #{@proposal.event}"
  end

end
