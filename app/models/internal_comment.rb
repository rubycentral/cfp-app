class InternalComment < Comment
  after_create :notify

  def mention_names
    body.scan(/@(\w+)/).flatten
  end

  private

  # Generate notifications for InternalComment

  # If a reviewer/organizer leaves a comment,
  # only the other reviewers of proposal get an in-app notification.
  # if the comment contains an @mention, the mentioned party gets a special notification and an email, regardless of whether they are a reviewer.
  def notify
    notify_unmentioned_reviewers
    notify_mentioned_event_staff if mention_names.any?
  end

  def notify_unmentioned_reviewers
    proposal.unmentioned_reviewers(mention_names, user_id).each do |reviewer|
      Notification.create_for(reviewer, proposal: proposal, message: "Internal comment on #{proposal.title}")
    end
  end

  def notify_mentioned_event_staff
    proposal.mentioned_event_staff(mention_names, user_id).each do |mentioned|
      teammate = mentioned.teammates.find{|t| t.event_id == proposal.event_id }
      mention = "@#{teammate.mention_name}"
      Notification.create_for(mentioned, proposal: proposal, message: "#{user.name} mentioned you in a new internal comment")
      CommentNotificationMailer.mention_notification(proposal, self, mentioned, mention)
        .deliver_now unless teammate.notification_preference == Teammate::IN_APP_ONLY
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
