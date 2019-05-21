
json.rooms current_event.rooms, :id, :name
json.days (1..current_event.days).to_a
json.slots current_event.time_slots, :conference_day, :id, :update_path, :start_time, :end_time, :program_session_id, :track_id, :room_id
json.sessions current_event.program_sessions
json.unscheduled_sessions current_event.program_sessions.unscheduled
json.counts EventStats.new(current_event).schedule_counts
json.tracks current_event.tracks.sort_by_name
json.csrf session[:_csrf_token]
