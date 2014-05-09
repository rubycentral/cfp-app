class Session < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :room
  belongs_to :track
  belongs_to :event
end

# == Schema Information
#
# Table name: sessions
#
#  id             :integer          not null, primary key
#  conference_day :integer
#  start_time     :datetime
#  end_time       :datetime
#  title          :text
#  description    :text
#  presenter      :text
#  room_id        :integer
#  track_id       :integer
#  proposal_id    :integer
#  event_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_sessions_on_event_id  (event_id)
#
