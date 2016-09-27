class TimeSlotSerializer < ActiveModel::Serializer
  attributes :conference_day, :start_time, :end_time, :program_session_id, :title, :presenter,
    :room, :track, :description

  #NOTE: object references a TimeSlotDecorator

  def room
    object.room_name
  end

  def track
    object.track_name
  end

  def title
    object.display_title
  end

  def presenter
    object.display_presenter
  end

  def description
    object.display_description
  end
end
