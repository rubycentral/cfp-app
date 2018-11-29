# frozen_string_literal: true

module FinalizationMessages
  MESSAGES = {
    Proposal::State::ACCEPTED   => ->(event_name) { "Your proposal for #{event_name} has been accepted" },
    Proposal::State::REJECTED   => ->(event_name) { "Your proposal for #{event_name} has not been accepted" },
    Proposal::State::WAITLISTED => ->(event_name) { "Your proposal for #{event_name} has been added to the waitlist" }
  }.freeze

  def subject_for(proposal:, type: proposal.state)
    default_builder = ->(_) { 'Invalid final proposal type' }
    subject_builder = MESSAGES[type] || default_builder
    subject_builder.call(proposal.event.name)
  end
end
