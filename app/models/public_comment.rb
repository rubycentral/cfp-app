class PublicComment < Comment

  after_create :notify

  private

  # Generate notifications for PublicComment
  # 1. If a speaker is leaving a comment,
  #      all reviewers/organizers get an in app notification
  #      if they have reviewed/rated or commented on the proposal.
  # 2. If anyone else (reviewer/program staff/organizer) leaves a comment,
  #      only the speakers get an in app and email notification.
  def notify
    begin
      if proposal.has_speaker?(user)
        @users = proposal.reviewers
        message = "Speaker commented on #{proposal.title}"
        CommentNotificationMailer.reviewer_notification(proposal, self,
                                    proposal.emailable_reviewers).deliver_now
      else
        @users = proposal.speakers.map(&:user)
        message = "New comment on #{proposal.title}"
        CommentNotificationMailer.speaker_notification(proposal, self, @users).deliver_now
      end
      @users.each do |user|
        Notification.create_for(user, proposal: proposal, message: message)
      end
    rescue => e
      logger.error("Comment Notification ran into an error: #{e.message}")
    end
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
