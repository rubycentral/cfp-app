module SessionHelper
  def track_options(session)
    selected = session.track.id if session.track

    options_from_collection_for_select(@event.tracks.all, :id, :name, selected)
  end

  def room_options(session)
    selected = session.room.id if session.room

    options_from_collection_for_select(@event.rooms.all, :id, :name, selected)
  end

  def unmet_requirements(event)
    @_unmet_requirements ||= event.unmet_requirements_for_scheduling.map do |msg|
      content_tag :li, msg, class: 'list-group-item custom-list-group-item-danger'
    end.join("\n").html_safe
  end

  def has_missing_requirements?(event)
    @_has_missing_requirements ||= unmet_requirements(event).present?
  end
end
