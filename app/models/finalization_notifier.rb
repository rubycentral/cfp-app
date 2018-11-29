# frozen_string_literal: true

class FinalizationNotifier
  include FinalizationMessages

  def self.notify(proposal)
    new(proposal).notify
  end

  attr_reader :proposal, :users
  def initialize(proposal)
    @proposal = proposal
    @users    = proposal.speakers.map(&:user)
  end

  def notify
    Staff::ProposalMailer.send_email(proposal).deliver_now

    message = subject_for(proposal: proposal)
    Notification.create_for_all(users, proposal: proposal, message: message)
  end
end
