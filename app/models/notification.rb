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
#  created_at  :datetime
#  updated_at  :datetime
#  message     :string(255)
#  read_at     :datetime
#  target_path :string(255)
#
# Indexes
#
#  index_notifications_on_person_id  (person_id)
#
