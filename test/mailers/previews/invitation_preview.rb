class InvitationPreview < ActionMailer::Preview
  def create
    ParticipantInvitationMailer.create(ParticipantInvitation.first)
  end
end