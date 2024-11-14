# frozen_string_literal: true

module Invitable
  extend ActiveSupport::Concern

  included do
    module State
      unless const_defined?(:DECLINED)
        DECLINED = 'declined'
        PENDING = 'pending'
        ACCEPTED = 'accepted'
      end
    end

    scope :pending, -> { where(state: State::PENDING) }
    scope :declined, -> { where(state: State::DECLINED) }
    scope :not_accepted, -> { where(state: [State::DECLINED, State::PENDING]) }

    before_create :set_default_state
    before_create :set_slug

    validates :email, presence: true
    validates_format_of :email, with: /@/
  end

  def decline
    update(state: State::DECLINED)
  end

  def pending?
    state == State::PENDING
  end

  def declined?
    state == State::DECLINED
  end

  private

  def set_slug
    self.slug = Digest::SHA1.hexdigest([email, rand(1000)].map(&:to_s).join('-'))[0, 10]
  end

  def set_default_state
    self.state = State::PENDING if state.nil?
  end
end
