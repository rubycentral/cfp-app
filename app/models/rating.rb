class Rating < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user

  scope :for_event, -> (event) { joins(:proposal).where("proposals.event_id = ?", event.id) }

  def participant
    user.participants.where(event: proposal.event).first
  end
end

# == Schema Information
#
# Table name: ratings
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  user_id     :integer
#  score       :integer
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_ratings_on_proposal_id  (proposal_id)
#  index_ratings_on_user_id      (user_id)
#
