class TimeSlotSerializer < ActiveModel::Serializer
  attributes :conference_day, :start_time, :end_time, :session_id, :program_session_id, :title, :presenter,
    :room_name, :track_name, :desc
end
