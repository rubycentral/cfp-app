class SessionSerializer < ActiveModel::Serializer
  attributes :conference_day, :start_time, :end_time, :proposal_id, :title, :presenter,
    :room_name, :track_name
end
