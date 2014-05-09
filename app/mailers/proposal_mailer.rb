class ProposalMailer < ActionMailer::Base
  def comment_notification(proposal, comment)
    @proposal = proposal
    @comment = comment

    bcc = @proposal.speakers.map do |speaker|
      speaker.email if speaker.person != @comment.person
    end

    if bcc.any?
      mail(bcc: bcc,
          subject: "You've received a comment on your proposal '#{@proposal.title}'")
    end
  end
end
