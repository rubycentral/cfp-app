class Organizer::ProposalMailer < ApplicationMailer

  def accept_email(event, proposal)
    @proposal = proposal.decorate
    @event = event

    mail_to_speakers(event, proposal,
        "Your proposal for #{@proposal.event.name} has been accepted")
  end

  def reject_email(event, proposal)
    @proposal = proposal
    @event = event

    mail_to_speakers(event, proposal,
       "Your proposal for #{@proposal.event.name} has not been accepted")
  end

  def waitlist_email(event, proposal)
    @proposal = proposal.decorate
    @event = event

    mail_to_speakers(event, proposal,
      "Your proposal for #{proposal.event.name} has been added to the waitlist")
  end

  private

  def mail_to_speakers(event, proposal, subject)
    to = proposal.speakers.map(&:email)
    if to.any?
      mail_markdown(
        from: event.contact_email,
        to: to,
        bcc: event.contact_email,
        subject: subject
      )
    end
  end
end
