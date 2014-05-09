module Invitable
  module State
    unless const_defined?(:REFUSED)
      REFUSED = 'refused'
      PENDING = 'pending'
      ACCEPTED = 'accepted'
    end
  end

  def self.included(klass)
    klass.scope :pending,      -> { klass.where(state: State::PENDING) }
    klass.scope :refused,      -> { klass.where(state: State::REFUSED) }
    klass.scope :not_accepted, -> { klass.where(state: [ State::REFUSED, State::PENDING ]) }

    klass.before_create :set_default_state
    klass.before_create :set_slug

    klass.validates :email, presence: true
    klass.validates_format_of :email, :with => /@/
  end

  def refuse
    self.update(state: State::REFUSED)
  end

  def accept
    self.update(state: State::ACCEPTED)
  end

  def pending?
    state == State::PENDING
  end

  def refused?
    state == State::REFUSED
  end

  private

  def set_slug
    self.slug = Digest::SHA1.hexdigest([email, rand(1000)].map(&:to_s).join('-'))[0,10]
  end

  def set_default_state
    self.state = State::PENDING if state.nil?
  end
end
