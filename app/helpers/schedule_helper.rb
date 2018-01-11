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

  def generate_grid_button(day)
    link_to('Generate Grid',
            new_event_staff_schedule_grid_bulk_time_slot_path(current_event, day),
            class: 'btn btn-primary btn-sm generate-grid',
            remote: true,
            data: {toggle: 'modal', target: '#bulk-time-slot-create-dialog'}
    )
  end

  def cancel_bulk_preview_button(day)
    link_to('Cancel',
            cancel_event_staff_schedule_grid_bulk_time_slot_path(current_event, day),
            class: 'btn btn-default btn-sm bulk-cancel',
            remote: true
    )
  end

  def session_format_duration_options
    current_event.session_formats.sort_by_name.map {|sf| ["#{sf.name} (#{sf.duration} min)", sf.duration]}
  end

end
