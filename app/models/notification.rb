class Notification < ApplicationRecord
  belongs_to :user
  UNREAD_LIMIT = 10

  scope :recent_unread, -> { unread.order(created_at: :desc).limit(UNREAD_LIMIT) }
  scope :unread, -> { where(read_at: nil) }

  def self.create_for_all(users, args = {})
    users.each { |user| create_for(user, args) }
  end

  def self.create_for(user, args = {})
    proposal = args.delete(:proposal)
    if proposal && args[:target_path].blank?
      args[:target_path] = user.decorate.proposal_notification_url(proposal)
    end
    user.notifications.create(args)
  end

  def self.mark_as_read_for_proposal(proposal_url)
    all.unread.where(target_path: proposal_url).update_all(read_at: DateTime.current)
  end

  def self.more_unread?
    unread.count > UNREAD_LIMIT
  end

  def self.more_unread_count
    more_unread? ? unread.count - UNREAD_LIMIT : 0
  end

  def mark_as_read
    update(read_at: DateTime.current)
  end

  def read?
    read_at.present?
  end

  def short_message
    message.truncate(50, omission: "...")
  end
end

# == Schema Information
#
# Table name: notifications
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  message     :string
#  target_path :string
#  read_at     :datetime
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_notifications_on_user_id  (user_id)
#
