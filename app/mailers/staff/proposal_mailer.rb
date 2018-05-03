class Staff::ProposalMailer < ApplicationMailer
  include FinalizationMessages

  attr_accessor :test_mode

  def send_email(proposal)
    case proposal.state
      when Proposal::State::ACCEPTED
        accept_email(proposal.event, proposal)
      when Proposal::State::REJECTED
        reject_email(proposal.event, proposal)
      when Proposal::State::WAITLISTED
        waitlist_email(proposal.event, proposal)
    end
  end

  def send_test_email(send_to, type_key, event)
    self.test_mode = true

    dummy_speaker = Speaker.new(speaker_name: 'Fake Name', speaker_email: send_to, event: event)
    dummy_proposal = Proposal.new(uuid: 'fake-uuid', title: 'Fake Title', event: event,
                                  state: SpeakerEmailTemplate::TYPES_TO_STATES[type_key])
    dummy_proposal.speakers << dummy_speaker

    send_email(dummy_proposal)
  end

  def accept_email(event, proposal)
    @proposal      = proposal.decorate
    @event         = event
    @template_name = 'accept_email'
    subject        = subject_for(proposal: @proposal, type: Proposal::State::ACCEPTED)
    mail_to_speakers(event, proposal, subject)
  end

  def reject_email(event, proposal)
    @proposal      = proposal
    @event         = event
    @template_name = 'reject_email'
    subject        = subject_for(proposal: @proposal, type: Proposal::State::REJECTED)
    mail_to_speakers(event, proposal, subject)
  end

  def waitlist_email(event, proposal)
    @proposal      = proposal.decorate
    @event         = event
    @template_name = 'waitlist_email'
    subject        = subject_for(proposal: proposal, type: Proposal::State::WAITLISTED)
    mail_to_speakers(event, proposal, subject)
  end

  private

  def mail_to_speakers(event, proposal, subject)
    to = proposal.speakers.map(&:email)
    if to.any?
      mail_markdown(
        from: event.contact_email,
        to: to,
        bcc: test_mode ? '' : event.contact_email,
        subject: subject
      )
    end
  end
end
