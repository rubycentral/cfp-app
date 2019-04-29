class Rating < ApplicationRecord
  belongs_to :proposal
  belongs_to :user

  scope :for_event, -> (event) { joins(:proposal).where("proposals.event_id = ?", event.id) }
  scope :not_withdrawn, -> { joins(:proposal).where("proposals.state != ?", Proposal::State::WITHDRAWN) }

  def teammate
    user.teammates.where(event: proposal.event).first
  end
end

# == Schema Information
#
# Table name: ratings
#
#  id          :bigint(8)        not null, primary key
#  proposal_id :bigint(8)
#  user_id     :bigint(8)
#  score       :integer
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_ratings_on_proposal_id  (proposal_id)
#  index_ratings_on_user_id      (user_id)
#
