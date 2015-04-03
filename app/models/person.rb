require 'digest/md5'

class Person < ActiveRecord::Base
  DEMOGRAPHICS      = [:gender, :ethnicity, :country]
  DEMOGRAPHIC_TYPES = {
    country: CountrySelect::countries.select{ |k,v| k != 'us'}.values.sort.unshift("United States of America")
  }

  store_accessor :demographics, :gender
  store_accessor :demographics, :ethnicity
  store_accessor :demographics, :country

  has_many :invitations,  dependent: :destroy
  has_many :services,     dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :reviewer_participants, -> { where(role: ['reviewer', 'organizer']) }, class_name: 'Participant'
  has_many :reviewer_events, through: :reviewer_participants, source: :event
  has_many :organizer_participants, -> { where(role: 'organizer') }, class_name: 'Participant'
  has_many :organizer_events, through: :organizer_participants, source: :event
  has_many :speakers,     dependent: :destroy
  has_many :ratings,      dependent: :destroy
  has_many :comments,     dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :proposals, through: :speakers, source: :proposal


  validates :email, uniqueness: { case_insensitive: true }, allow_nil: true
  validates :bio, length: { maximum: 500 }
  validates :name, :presence => true, allow_nil: true

  def self.authenticate(auth, current_user = nil)
    provider = auth['provider']
    uid      = auth['uid'].to_s
    service  = Service.where(provider: provider, uid: uid).first ||
    Service.create(provider: provider, uid: uid, uname: auth['info']['name'], uemail: auth['info']['email'])

    user = if current_user
      current_user.services << service
      current_user
    else
      logger.info "No existing person making new"
      service.person.present? ? service.person : create_for_service(service, auth)
    end

    return service, user
  end

  def self.create_for_service(service, auth)
    email = auth['info']['email'].blank? ? nil : auth['info']['email']
    person = create({
      name:  auth['info']['name'],
      email: email
    })
    unless person.valid?
      Rails.logger.warn "UNEXPECTED! Person is not valid - Errors: #{person.errors.messages}"
    end
    person.services << service
    person
  end
  private_class_method :create_for_service

  def assign_open_invitations
    if email
      Invitation.where("LOWER(email) = ? AND state = ? AND person_id IS NULL",
        email.downcase, Invitation::State::PENDING).each do |invitation|
        invitation.update_column(:person_id, id)
      end
    end
  end

  def update_bio
    update(bio: speakers.last.bio) if bio.blank?
  end

  def gravatar_hash
    Digest::MD5.hexdigest email.to_s.downcase
  end

  def connected?(provider)
    self.services.detect {|s| s.provider == provider}
  end

  def complete?
    self.name.present? && self.email.present?
  end

  def demographics_complete?
    gender.present? && ethnicity.present? && country.present?
  end

  def organizer?
    organizer_events.count > 0
  end

  def organizer_for_event?(event)
    participants.organizer.for_event(event).size > 0
  end

  def reviewer?
    reviewer_events.count > 0
  end

  def reviewer_for_event?(event)
    participants.reviewer.for_event(event).size > 0
  end

  def rating_for(proposal, build_new = true)
    rating = ratings.detect { |r| r.proposal_id == proposal.id }
    if rating
      rating
    elsif build_new
      ratings.build(proposal: proposal)
    end
  end

  def role_names
    self.participants.collect {|p| p.role}.uniq.join(", ")
  end

end

# == Schema Information
#
# Table name: people
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  email        :string(255)
#  bio          :text
#  demographics :hstore
#  admin        :boolean          default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#
