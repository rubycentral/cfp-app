class Event < ActiveRecord::Base
  store_accessor :speaker_notification_emails, :accept
  store_accessor :speaker_notification_emails, :reject
  store_accessor :speaker_notification_emails, :waitlist

  has_many :participants, dependent: :destroy
  has_many :proposals,    dependent: :destroy
  has_many :speakers,     through: :proposals
  has_many :rooms,        dependent: :destroy
  has_many :tracks,       dependent: :destroy
  has_many :sessions,       dependent: :destroy
  has_many :taggings, through: :proposals
  has_many :ratings, through: :proposals
  has_many :participant_invitations

  serialize :proposal_tags, Array
  serialize :review_tags, Array

  scope :recent, -> { order('name ASC') }
  scope :live, -> { where("state = 'open' and (closes_at is null or closes_at > ?)", Time.current).order('closes_at ASC') }

  validates :name, :contact_email, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug


  def valid_proposal_tags
    proposal_tags.join(', ')
  end

  def valid_proposal_tags=(tags_string)
    self.proposal_tags = Tagging.tags_string_to_array(tags_string)
  end

  def valid_review_tags
    review_tags.join(', ')
  end

  def valid_review_tags=(tags_string)
    self.review_tags = Tagging.tags_string_to_array(tags_string)
  end

  def generate_slug
    self.slug = name.parameterize if slug.blank?
  end

  def to_s
    name
  end

  def open?
    state == 'open' && (closes_at.nil? || closes_at > Time.current)
  end

  def closed?
    ! open?
  end

  def past_open?
    state == 'open' && closes_at < Time.current
  end

  def unmet_requirements_for_scheduling
    missing_prereqs = []

    missing_prereqs << "Event must have a start date" unless start_date
    missing_prereqs << "Event must have a end date" unless end_date

    unless rooms.size > 0
      missing_prereqs << "Event must have at least one room"
    end

    missing_prereqs
  end

  def archive
    if current?
      update_attribute(:archived, true)
    end
  end

  def unarchive
    if archived?
      update_attribute(:archived, false)
    end
  end

  def current?
    ! archived?
  end

  def cfp_opens
    opens_at && opens_at.to_s(:long_with_zone)
  end

  def cfp_closes
    closes_at && closes_at.to_s(:long_with_zone)
  end

  def conference_date(conference_day)
    start_date + (conference_day - 1).days
  end
end

# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  slug                        :string(255)
#  url                         :string(255)
#  contact_email               :string(255)
#  state                       :string(255)      default("closed")
#  opens_at                    :datetime
#  closes_at                   :datetime
#  start_date                  :datetime
#  end_date                    :datetime
#  proposal_tags               :text
#  review_tags                 :text
#  guidelines                  :text
#  policies                    :text
#  speaker_notification_emails :hstore           default({"accept"=>"", "reject"=>"", "waitlist"=>""})
#  created_at                  :datetime
#  updated_at                  :datetime
#  archived                    :boolean          default(FALSE)
#
# Indexes
#
#  index_events_on_slug  (slug)
#
