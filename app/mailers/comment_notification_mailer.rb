class CommentNotificationMailer < ActionMailer::Base
  def email_notification(comment)
    @comment = comment


    bcc = @comment.proposal.event.participants.map do |participant|
      if participant.notifications
      end
    end

    if bcc.any?
      mail(bcc: bcc,
           from: @proposal.event.contact_email,
           subject: "A comment has been posted")
    end
  end
end
