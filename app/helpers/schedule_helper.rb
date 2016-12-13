module ScheduleHelper

  def row_time(time_slot)
    if time_slot && time_slot.start_time
      fmt = "%l:%M%p"
      "#{time_slot.start_time.strftime(fmt)} - #{time_slot.end_time.strftime(fmt)}"
    end
  end

  def grid_data
    tracks = current_event.tracks.sort_by_name.pluck(:name).map(&:parameterize)
    {
        tracks_css: tracks
    }
  end

  def grid_position_css(room)
    'no-grid-position' if room.grid_position.blank?
  end

  def current_day_css(day, current_day)
    'active' if day == current_day
  end

end