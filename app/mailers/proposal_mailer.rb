class ProposalMailer < ApplicationMailer
  def comment_notification(proposal, comment)
    @proposal = proposal
    @comment = comment

    to = @proposal.speakers.map do |speaker|
      speaker.email if speaker.person != @comment.person
    end

    if to.any?
      mail_markdown(to: @proposal.speakers.map(&:email),
                    from: @proposal.event.contact_email,
                    subject: "CFP #{@proposal.event.name}: You've received a comment on your proposal '#{@proposal.title}'")
    end
  end
end
