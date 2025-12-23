module Proposal::State
  extend ActiveSupport::Concern

  SOFT_STATES = [:soft_accepted, :soft_waitlisted, :soft_rejected, :submitted].freeze
  FINAL_STATES = [:accepted, :waitlisted, :rejected, :withdrawn, :not_accepted].freeze

  SOFT_TO_FINAL = {
    soft_accepted: :accepted,
    soft_rejected: :rejected,
    soft_waitlisted: :waitlisted,
    submitted: :rejected
  }.with_indifferent_access.freeze

  BECOMES_PROGRAM_SESSION = [:accepted, :waitlisted].freeze

  included do
    enum :state, {
      submitted: 'submitted',
      soft_accepted: 'soft accepted',
      soft_waitlisted: 'soft waitlisted',
      soft_rejected: 'soft rejected',
      accepted: 'accepted',
      waitlisted: 'waitlisted',
      rejected: 'rejected',
      withdrawn: 'withdrawn',
      not_accepted: 'not accepted'
    }, default: :submitted
    def self.valid_states
      @valid_states ||= Proposal::State.constants.map{|c| const_get(c) if const_get(c).is_a?(String)}.compact!
    end

    # Create all state accessor methods like (accepted?, waitlisted?, etc...)
    Proposal::State.constants.each do |constant|
      next unless const_get(constant).is_a?(String)
      method_name = constant.to_s.downcase + '?'
      define_method(method_name) do
        Proposal::State.const_get(constant) == self.state
      end
    end
  end
end
