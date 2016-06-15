class Speaker < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user

  has_many :proposals, through: :user

  delegate :name, :email, :gravatar_hash, to: :user

  validates :bio, length: {maximum: 500}

  accepts_nested_attributes_for :user

end

# == Schema Information
#
# Table name: speakers
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  user_id     :integer
#  bio         :text
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_speakers_on_proposal_id  (proposal_id)
#  index_speakers_on_user_id      (user_id)
#
