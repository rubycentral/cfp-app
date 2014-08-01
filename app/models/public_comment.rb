class PublicComment < Comment

  after_create :create_notifications, :send_emails

  private

  # Send emails to speakers when reviewer creates a comment
  def send_emails
    if person.reviewer_for_event?(proposal.event)
      ProposalMailer.comment_notification(proposal, self).deliver
    end
  end

  # Generate notifications and email for Comment
  # 1. If a speaker is leaving a comment,
  #    all reviewers/organizers get an in app notification
  #      if they have reviewed or commented on the proposal.
  # 2. If a a reviewer/organizer leaves a comment,
  #      only the speakers get an in app and email notification.
  def create_notifications

    if person.reviewer_for_event?(proposal.event)
      people = proposal.speakers.map(&:person)
      message = "#{person.name} has commented on #{proposal.title}"
    else
      people = proposal.reviewers
      message = "The author has commented on #{proposal.title}"
    end

    Notification.create_for(people, proposal: proposal, message: message)
  end
end

# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  person_id   :integer
#  parent_id   :integer
#  body        :text
#  type        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_comments_on_person_id    (person_id)
#  index_comments_on_proposal_id  (proposal_id)
#
