# frozen_string_literal: true

class Proposal < ApplicationRecord
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
  }, default: :submitted do
    event :soft_accept do
      transition :submitted => :soft_accepted
    end

    event :soft_waitlist do
      transition :submitted => :soft_waitlisted
    end

    event :soft_reject do
      transition :submitted => :soft_rejected
    end

    event :withdraw do
      transition all - [:withdrawn] => :withdrawn

      after do
        reviewers.each do |reviewer|
          Notification.create_for(reviewer, proposal: self, message: "Proposal, #{title}, withdrawn")
        end
      end
    end

    event :promote do
      transition :waitlisted => :accepted
    end

    event :decline do
      transition [:accepted, :waitlisted] => :withdrawn

      before do
        self.confirmed_at = Time.current
      end

      after do
        program_session.update(state: :declined)
      end
    end

    event :finalize do
      transition :soft_accepted => :accepted
      transition :soft_rejected => :rejected
      transition :soft_waitlisted => :waitlisted
      transition :submitted => :rejected

      after do
        ProgramSession.create_from_proposal(self) if becomes_program_session?
      end
    end

    event :reset do
      transition [:soft_accepted, :soft_waitlisted, :soft_rejected] => :submitted
    end

    event :hard_reset do
      transition [:accepted, :waitlisted, :rejected] => :submitted
    end
  end

  SOFT_STATES = [:soft_accepted, :soft_waitlisted, :soft_rejected, :submitted].freeze
  FINAL_STATES = [:accepted, :waitlisted, :rejected, :withdrawn, :not_accepted].freeze

  has_many :public_comments, dependent: :destroy
  has_many :internal_comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :speakers, -> { order created_at: :asc }, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :proposal_taggings, -> { proposal }, class_name: 'Tagging'
  has_many :review_taggings, -> { review }, class_name: 'Tagging'
  has_many :invitations, dependent: :destroy

  belongs_to :event
  has_one :program_session
  belongs_to :session_format
  belongs_to :track, optional: true

  validates :title, :abstract, :session_format, presence: true
  validate :abstract_length
  validates :title, length: { maximum: 60 }
  validate :state_must_be_final_for_confirmation, if: :confirmed_at_changed?

  serialize :last_change, coder: YAML
  serialize :proposal_data, type: Hash, coder: YAML

  has_paper_trail only: %i[title abstract details pitch]

  attr_accessor :updating_user
  attr_writer :tags, :review_tags

  accepts_nested_attributes_for :public_comments, reject_if: proc { |comment_attributes| comment_attributes[:body].blank? }
  accepts_nested_attributes_for :speakers

  before_create :set_uuid, :set_updated_by_speaker_at
  before_update :save_attr_history
  after_save :save_tags, :save_review_tags

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :soft_states, -> { where(state: SOFT_STATES) }
  scope :working_program, -> { where(state: [:soft_accepted, :soft_waitlisted, :accepted, :waitlisted]) }

  scope :unrated, -> { where.not(id: Rating.select(:proposal_id)) }
  scope :rated, -> { where(id: Rating.select(:proposal_id)) }
  scope :not_owned_by, ->(user) { where.not(id: user.proposals) }
  scope :in_track, ->(track_id) { where(track_id: track_id.presence) }

  scope :emails, -> { joins(speakers: :user).pluck(:email).uniq }

  # Return all reviewers for this proposal.
  # A user is considered a reviewer if they meet the following criteria
  # - They are an teammate for this event
  # AND
  # - They have rated or made a public comment on this proposal, and are not a speaker on this proposal
  def reviewers
    User.joins(:teammates,
               'LEFT OUTER JOIN ratings AS r ON r.user_id = users.id',
               'LEFT OUTER JOIN comments AS c ON c.user_id = users.id')
        .where("teammates.event_id = ? AND (r.proposal_id = ? or (c.proposal_id = ? AND c.type = 'PublicComment'))",
               event.id, id, id)
        .where.not(id: speakers.map(&:user_id)).distinct
  end

  def emailable_reviewers
    reviewers.merge(Teammate.all_emails)
  end

  def unmentioned_reviewers(mention_names, commenter_id)
    reviewers.where.not(id: commenter_id)
             .where.not(teammates: { mention_name: mention_names })
  end

  def mentioned_event_staff(mention_names, commenter_id)
    event.staff.includes(:teammates)
         .where.not(id: commenter_id)
         .where(teammates: { event: event, mention_name: mention_names })
  end

  # Return all proposals from speakers of this proposal. Does not include this proposal.
  def other_speakers_proposals
    proposals = []
    speakers.each do |speaker|
      speaker.proposals.each do |p|
        proposals << p if p.id != id && p.event_id == event.id
      end
    end
    proposals
  end

  def custom_fields=(custom_fields)
    proposal_data[:custom_fields] = custom_fields
  end

  def custom_fields
    proposal_data[:custom_fields] || {}
  end

  def confirm
    update(confirmed_at: Time.current)
    program_session.confirm if program_session.present?
  end

  # draft? is an alias for submitted?
  def draft?
    submitted?
  end

  def finalized?
    FINAL_STATES.include?(state.to_sym)
  end

  def becomes_program_session?
    accepted? || waitlisted?
  end

  def confirmed?
    confirmed_at.present?
  end

  def awaiting_confirmation?
    finalized? && (accepted? || waitlisted?) && !confirmed?
  end

  def speaker_can_edit?(user)
    has_speaker?(user) && !(withdrawn? || accepted? || confirmed?)
  end

  def speaker_can_withdraw?(user)
    speaker_can_edit?(user) && has_reviewer_activity?
  end

  def speaker_can_delete?(user)
    speaker_can_edit?(user) && !has_reviewer_activity?
  end

  def to_param
    uuid
  end

  def average_rating
    return nil if ratings.empty?

    ratings.map(&:score).inject(:+).to_f / ratings.size
  end

  def standard_deviation
    unless ratings.empty?
      scores = ratings.map(&:score)

      squared_reducted_total = 0.0
      average = scores.inject(:+) / scores.length.to_f

      scores.each do |score|
        squared_reducted_total += (score - average)**2
      end
      Math.sqrt(squared_reducted_total / scores.length)
    end
  end

  def has_speaker?(user)
    if speakers.loaded?
      speakers.any? {|s| s.user_id == user.id }
    else
      speakers.where(user_id: user).exists?
    end
  end

  def has_invited?(user)
    user.pending_invitations.map(&:proposal_id).include?(id)
  end

  def tags
    proposal_taggings.to_a.map(&:tag)
  end

  def review_tags
    review_taggings.to_a.map(&:tag)
  end

  def has_reviewer_comments?
    has_public_reviewer_comments? || has_internal_reviewer_comments?
  end

  def speaker_update_and_notify(attributes)
    old_title = title
    speaker_updates = attributes.merge({ updated_by_speaker_at: Time.current })
    if update(speaker_updates)
      field_names = last_change.join(', ')
      reviewers.each do |reviewer|
        Notification.create_for(reviewer, proposal: self,
                                          message: "Proposal, #{old_title}, updated [ #{field_names} ]")
      end
    end
  end

  def has_reviewer_activity?
    ratings.present? || has_reviewer_comments?
  end

  def changeset_fields
    versions[1..]&.map(&:changeset)&.flat_map(&:keys)&.uniq
  end

  private

  def state_must_be_final_for_confirmation
    errors.add(:state, "'#{state}' not a confirmable state.") unless finalized?
  end

  def abstract_length
    return unless abstract_changed? && abstract.gsub(/\r/, '').gsub(/\n/, '').length > 600

    errors.add(:abstract, 'is too long (maximum is 600 characters)')
  end

  def save_tags
    update_tags(proposal_taggings, @tags, false) if @tags
  end

  def save_review_tags
    update_tags(review_taggings, @review_tags, true) if @review_tags
  end

  def update_tags(old, new, internal)
    old.destroy_all
    tags = new.uniq.sort.map do |t|
      { tag: t.strip, internal: internal } if t.present?
    end.compact
    taggings.create(tags)
  end

  def has_public_reviewer_comments?
    public_comments.reject { |comment| speakers.include?(comment.user_id) }.any?
  end

  def has_internal_reviewer_comments?
    internal_comments.reject { |comment| speakers.include?(comment.user_id) }.any?
  end

  def save_attr_history
    if updating_user&.organizer_for_event?(event)
      # Erase the record of last change if the proposal is updated by an
      # organizer
      self.last_change = nil
    else
      changes_whitelist = %w[pitch abstract details title]
      self.last_change = changes_whitelist & changed
    end
  end

  def set_uuid
    self.uuid = Digest::SHA1.hexdigest([event_id, title, created_at, rand(100)].map(&:to_s).join('-'))[0, 10]
  end

  def set_updated_by_speaker_at
    self.updated_by_speaker_at = Time.current
  end
end

# == Schema Information
#
# Table name: proposals
#
#  id                    :integer          not null, primary key
#  event_id              :integer
#  state                 :string           default("submitted")
#  uuid                  :string
#  title                 :string
#  session_format_id     :integer
#  track_id              :integer
#  abstract              :text
#  details               :text
#  pitch                 :text
#  last_change           :text
#  confirmation_notes    :text
#  proposal_data         :text
#  updated_by_speaker_at :datetime
#  confirmed_at          :datetime
#  created_at            :datetime
#  updated_at            :datetime
#
# Indexes
#
#  index_proposals_on_event_id           (event_id)
#  index_proposals_on_session_format_id  (session_format_id)
#  index_proposals_on_track_id           (track_id)
#  index_proposals_on_uuid               (uuid) UNIQUE
#
