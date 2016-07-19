class CommentNotificationMailer < ApplicationMailer

  def reviewer_notification(proposal, comment, users)
    @comment = comment
    @proposal = proposal

    # Email all reviewers of this proposal if notifications is true unless they made the comment
    to = users.map(&:email)

    if to.any?
      mail_markdown(
                    to: to,
                    from: @proposal.event.contact_email,
                    subject: "#{@proposal.event.name} CFP: New comment on '#{@proposal.title}'")
    end
  end

  def speaker_notification(proposal, comment, users)
    @proposal = proposal
    @comment = comment

    to = users.map(&:email)

    if to.any?
      mail_markdown(to: to,
                    from: @proposal.event.contact_email,
                    subject: "#{@proposal.event.name} CFP: New comment on '#{@proposal.title}'")
    end
  end

end

