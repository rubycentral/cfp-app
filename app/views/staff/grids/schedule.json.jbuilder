
json.rooms current_event.rooms, :id, :name
json.days (1..current_event.days).to_a
json.slots current_event.time_slots
json.sessions current_event.program_sessions
json.unscheduledSessions current_event.program_sessions.unscheduled
json.counts EventStats.new(current_event).schedule_counts
json.tracks current_event.tracks.sort_by_name
json.bulkPath event_staff_schedule_grid_bulk_time_slot_path(current_event)
json.sessionFormats current_event.session_formats
