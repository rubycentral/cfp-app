# == Schema Information
#
# Table name: sessions
#
#  id             :integer          not null, primary key
#  conference_day :integer
#  start_time     :time
#  end_time       :time
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

class SessionSerializer < ActiveModel::Serializer
  attributes :conference_day, :start_time, :end_time, :session_id, :proposal_id, :title, :presenter,
    :room_name, :track_name, :desc
end
