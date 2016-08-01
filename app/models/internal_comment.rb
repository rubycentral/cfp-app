class InternalComment < Comment
  after_create :notify

  private

  # Generate notifications for InternalComment

  # If a reviewer/organizer leaves a comment,
  #  only the other reviewers of proposal get an in-app notification.
  def notify
    reviewers = proposal.reviewers.reject{|r| r.id == user_id }
    Notification.create_for(reviewers, proposal: proposal, message: "Internal comment on #{proposal.title}")
  end
end

# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  user_id     :integer
#  parent_id   :integer
#  body        :text
#  type        :string
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_comments_on_proposal_id  (proposal_id)
#  index_comments_on_user_id      (user_id)
#
