class Notification < ActiveRecord::Base
  belongs_to :person

  scope :recent, -> { unread.order(created_at: :desc).limit(15) }
  scope :unread, -> { where(read_at: nil) }

  def self.create_for(people, args = {})
    proposal = args.delete(:proposal)
    people.each do |person|
      args[:target_path] = person.decorate.proposal_path(proposal) if proposal
      person.notifications.create(args)
    end
  end

  def self.mark_as_read_for_proposal(proposal_path)
    all.unread.where(target_path: proposal_path).update_all(read_at: DateTime.now)
  end

  def read
    update(read_at: DateTime.now)
  end

  def read?
    read_at.present?
  end
end

# == Schema Information
#
# Table name: notifications
#
#  id          :integer          not null, primary key
#  person_id   :integer
#  message     :string
#  read_at     :datetime
#  target_path :string
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_notifications_on_person_id  (person_id)
#
