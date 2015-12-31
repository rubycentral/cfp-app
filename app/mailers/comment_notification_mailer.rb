class CommentNotificationMailer < ApplicationMailer
  def email_notification(comment)
    @comment = comment
    @proposal = comment.proposal

    # Email all reviewers of this proposal if notifications is true unless they made the comment
    bcc = @proposal.event.ratings.map do |rating|
      person = rating.person
      if rating.participant.should_be_notified? && @comment.person_id != person.id
        person.email
      end
    end.compact

    if bcc.any?
      mail_markdown(bcc: bcc,
                    from: @proposal.event.contact_email,
                    subject: "A comment has been posted on #{@proposal.title}")
    end
  end
end

