class ParticipantInvitation < ActiveRecord::Base
  include Invitable

  before_create :generate_token

  belongs_to :event

  validates_uniqueness_of :email, scope: :event

  def create_participant(person)
    event.participants.create(person: person, role: role)
  end

  private

  def generate_token
    self.token = Digest::SHA1.hexdigest(Time.now.to_s + email + rand(1000).to_s)
  end
end

# == Schema Information
#
# Table name: participant_invitations
#
#  id         :integer          not null, primary key
#  email      :string
#  state      :string
#  slug       :string
#  role       :string
#  token      :string
#  event_id   :integer
#  created_at :datetime
#  updated_at :datetime
#
