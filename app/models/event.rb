class Event < ActiveRecord::Base
  has_many :teammates, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :speakers
  has_many :rooms, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :time_slots, dependent: :destroy
  has_many :program_sessions, dependent: :destroy
  has_many :session_formats, dependent: :destroy
  has_many :taggings, through: :proposals
  has_many :ratings, through: :proposals

  has_many :public_session_formats, ->{ where(public: true) }, class_name: SessionFormat

  accepts_nested_attributes_for :proposals

  serialize :proposal_tags, Array
  serialize :review_tags, Array
  serialize :custom_fields, Array
  serialize :settings, Hash
  serialize :speaker_notification_emails, Hash

  store_accessor :speaker_notification_emails, :accept
  store_accessor :speaker_notification_emails, :reject
  store_accessor :speaker_notification_emails, :waitlist


  scope :a_to_z, -> { order('name ASC') }
  scope :closes_up, -> { order('closes_at ASC') }
  scope :live, -> { where("state = 'open' and (closes_at is null or closes_at > ?)", Time.current) }
  scope :not_draft, -> { where "state != 'draft'"}

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validate :url_must_be_valid, if: :url?

  before_validation :generate_slug
  before_save :update_closes_at_if_manually_closed

  STATUSES = { open: 'open',
               draft: 'draft',
               closed: 'closed' }

  def to_param
    slug
  end

  with_options on: :update, if: :open? do
    validates :public_session_formats, presence: { message: 'A least one public session format must be defined before event can be opened.' }
    validates :guidelines, presence: { message: 'Guidelines must be defined before event can be opened.' }
  end

  def remove_speaker_email_template(template)
    attr = SpeakerEmailTemplate::TYPES.find { |type| type == template }
    if attr
      update_attribute(attr, "")
    end
  end

  def public_tags?
    proposal_tags.any?
  end

  def valid_proposal_tags
    proposal_tags.join(', ')
  end

  def valid_proposal_tags=(tags_string)
    self.proposal_tags = Tagging.tags_string_to_array(tags_string)
  end

  def reviewer_tags?
    review_tags.any?
  end

  def valid_review_tags
    review_tags.join(', ')
  end

  def valid_review_tags=(tags_string)
    self.review_tags = Tagging.tags_string_to_array(tags_string)
  end

  def custom_fields_string=(custom_fields_string)
    self.custom_fields = self.custom_fields_string_to_array(custom_fields_string)
  end

  def custom_fields_string_to_array(string)
    (string || '').split(',').map(&:strip).reject(&:blank?).uniq
  end

  def custom_fields_string
    custom_fields.join(', ')
  end

  def fields
    self.proposals.column_names.join(', ')
  end

  def multiple_tracks?
    tracks.any?
  end

  def multiple_public_session_formats?
    session_formats.publicly_viewable.count > 1
  end

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end

  def to_s
    name
  end

  def draft?
    state == STATUSES[:draft]
  end

  def open?
    state == STATUSES[:open] && (closes_at.nil? || closes_at > Time.current)
  end

  def closed?
    !open? && !draft?
  end

  def past_open?
    state == STATUSES[:open] && closes_at < Time.current
  end

  def status
    if open?
      STATUSES[:open]
    elsif draft?
      STATUSES[:draft]
    else
    STATUSES[:closed]
    end
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

  def incomplete_checklist_items
    missing_items = []

    missing_items << "Event must have a url" unless url.present?
    missing_items << "Event must have a start date" unless start_date
    missing_items << "Event must have an end date" unless end_date
    missing_items << "Event must have a contact email" unless contact_email.present?
    missing_items << "Event must have a CFP closes at date set for a future date" unless closes_at && (closes_at > Time.current)
    missing_items << "Event must have at least one public session format" unless public_session_formats.present?
    missing_items << "Event must have guidelines" unless guidelines.present?

    missing_items
  end

  def open_cfp
    if incomplete_checklist_items.empty?
      update_attribute(:state, STATUSES[:open])
      true
    else
      errors.add(incomplete_checklist_items.join("; "))
      false
    end
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
    !archived?
  end

  def cfp_opens
    opens_at.try(:to_s, :long_with_zone)
  end

  def cfp_closes
    closes_at.try(:to_s, :long_with_zone)
  end

  def conference_date(conference_day)
    start_date + (conference_day - 1).days
  end

  def url_must_be_valid
    uri = URI.parse(url)
    unless uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
      errors.add(:url, "must start with http:// or https://")
    end
  rescue URI::InvalidURIError
    errors.add(:url, "must be valid")
  end

  def stats
    @stats ||= EventStats.new(self)
  end

  def days
    (end_date.to_date - start_date.to_date).to_i + 1
  end

  private

  def update_closes_at_if_manually_closed
    if changes.key?(:state) && changes[:state] == [STATUSES[:open], STATUSES[:closed]]
      self.closes_at = DateTime.now
    end
  end
end

# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  name                        :string
#  slug                        :string
#  url                         :string
#  contact_email               :string
#  state                       :string           default("draft")
#  archived                    :boolean          default(FALSE)
#  opens_at                    :datetime
#  closes_at                   :datetime
#  start_date                  :datetime
#  end_date                    :datetime
#  info                        :text
#  guidelines                  :text
#  settings                    :text
#  proposal_tags               :text
#  review_tags                 :text
#  custom_fields               :text
#  speaker_notification_emails :text             default({:accept=>"", :reject=>"", :waitlist=>""})
#  created_at                  :datetime
#  updated_at                  :datetime
#
# Indexes
#
#  index_events_on_slug  (slug)
#
