class CommentNotificationMailer < ActionMailer::Base
  def create(comment)
    # @comment = participant_invitation
    # @event = participant_invitation.event

    mail to: participant.email,
         from: @event.contact_email,
         subject: "A comment has been posted"
  end
end