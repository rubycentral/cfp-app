# frozen_string_literal: true

module FinalizationMessages
  MESSAGES = {
    accepted: ->(event_name) { "Your proposal for #{event_name} has been accepted" },
    rejected: ->(event_name) { "Your proposal for #{event_name} has not been accepted" },
    waitlisted: ->(event_name) { "Your proposal for #{event_name} has been added to the waitlist" }
  }.with_indifferent_access.freeze

  def subject_for(proposal:, type: proposal.state)
    default_builder = ->(_) { 'Invalid final proposal type' }
    subject_builder = MESSAGES[type] || default_builder
    subject_builder.call(proposal.event.name)
  end
end
