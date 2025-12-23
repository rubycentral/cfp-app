class Invitation < ApplicationRecord
  module State
    DECLINED = 'declined'
    PENDING = 'pending'
    ACCEPTED = 'accepted'
  end
  enum :state, {pending: 'pending', accepted: 'accepted', declined: 'declined'}

  belongs_to :proposal
  belongs_to :user, optional: true

  scope :not_accepted, -> { where(state: [:pending, :declined]) }

  before_create :set_default_state
  before_create :set_slug

  validates :email, presence: true
  validates_format_of :email, with: /@/

  def accept(user)
    transaction do
      self.user = user
      self.state = :accepted
      proposal.speakers.create(user: user, event: proposal.event, skip_name_email_validation: true)
      save
    end
  end

  def decline
    update(state: :declined)
  end

  private

  def set_slug
    self.slug = Digest::SHA1.hexdigest([email, rand(1000)].map(&:to_s).join('-'))[0, 10]
  end

  def set_default_state
    self.state = :pending if state.nil?
  end
end

# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  user_id     :integer
#  email       :string
#  state       :string           default("pending")
#  slug        :string
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_invitations_on_proposal_id            (proposal_id)
#  index_invitations_on_proposal_id_and_email  (proposal_id,email) UNIQUE
#  index_invitations_on_slug                   (slug) UNIQUE
#  index_invitations_on_user_id                (user_id)
#
