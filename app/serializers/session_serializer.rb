class SessionSerializer < ActiveModel::Serializer
  attributes :conference_day, :start_time, :end_time, :title, :presenter,
    :room_name, :track_name
end
