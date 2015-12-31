class Rating < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :person

  scope :for_event, -> (event) { joins(:proposal).where("proposals.event_id = ?", event.id) }

  def participant
    @participant ||= person.participants.where(event: proposal.event).first
  end
end

# == Schema Information
#
# Table name: ratings
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  person_id   :integer
#  score       :integer
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_ratings_on_person_id    (person_id)
#  index_ratings_on_proposal_id  (proposal_id)
#
