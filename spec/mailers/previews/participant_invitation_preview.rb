class ParticipantInvitationPreview < ActionMailer::Preview
  def create
    ParticipantInvitationMailer.create(ParticipantInvitation.first)
  end
end