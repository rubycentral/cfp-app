class EventTeammateInvitationPreview < ActionMailer::Preview
  def create
    EventTeammateInvitationMailer.create(EventTeammateInvitation.first)
  end
end
