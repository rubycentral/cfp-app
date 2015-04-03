class Speaker < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :person


  has_many :proposals, through: :person

  delegate :name, :email, :gravatar_hash, to: :person

  validates :bio, length: { maximum: 500 }

  accepts_nested_attributes_for :person
end

# == Schema Information
#
# Table name: speakers
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  person_id   :integer
#  bio         :text
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_speakers_on_person_id    (person_id)
#  index_speakers_on_proposal_id  (proposal_id)
#
