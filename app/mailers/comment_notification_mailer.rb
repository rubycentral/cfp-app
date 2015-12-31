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

# 3 reviewers, reviewer who is making the comment & has already rated, someone who has rated but didn't make comment (both have notifications turned on), has notifications turned off
# Speaker notifications as well
# Make sure logic still works 
