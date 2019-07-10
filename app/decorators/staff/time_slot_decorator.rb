class Staff::TimeSlotDecorator < Draper::Decorator
  decorates :time_slot
  delegate_all

  def start_time
    object.start_time.try(:to_s, :time_p)
  end

  def end_time
    object.end_time.try(:to_s, :time_p)
  end

  def session_duration
    "#{object.session_duration.try(:to_s, :time)} minutes"
  end

  def time_slot_id
    object.id
  end

 def row_data_time_sortable(buttons: false)
   row = [object.conference_day, object.start_time, object.end_time, linked_title,
     display_presenter, object.room_name, display_track_name]
     row << action_links if buttons
     row
 end

  def row_data(buttons: false)
    row = [object.conference_day, start_time, end_time, linked_title,
           display_presenter, object.room_name, display_track_name]

    row << action_links if buttons
    row
  end

  def row
    {id: object.id, values: row_data(buttons: true)}
  end

  def action_links
    [
      h.link_to('Edit',
                h.edit_event_staff_schedule_time_slot_path(object.event, object),
                class: 'btn btn-primary btn-xs',
                remote: true,
                data: {toggle: 'modal', target: "#time-slot-edit-dialog"}),

      h.link_to('Remove',
                h.event_staff_schedule_time_slot_path(object.event, object),
                method: :delete,
                data: {confirm: "Are you sure you want to remove this time slot?"},
                remote: true,
                class: 'btn btn-danger btn-xs')
    ].join("\n").html_safe
  end

  def unscheduled_program_sessions
    program_sessions = object.event.program_sessions.unscheduled.sorted_by_title.to_a

    if object.program_session
      program_sessions.unshift(object.program_session)
    end

    program_sessions.map do |ps|
      [ps.title, ps.id, { selected: ps == object.program_session, data: {
          title: ps.title,
          track: ps.track_name,
          speaker: ps.speaker_names,
          abstract: ps.abstract,
          duration: ps.session_format.duration
      }}]
    end
  end

  def linked_title
    if object.program_session.present?
      h.link_to(object.session_title,
                h.event_staff_program_session_path(object.event, object.program_session))
    else
      object.title
    end
  end

  def conference_wide_title
    display_title + ": " + room_name
  end

  def supplemental_fields_visibility_css
    object.program_session.present? ? 'hidden' : ''
  end

  def cell_data_attr
    {"time-slot-edit-path" => h.edit_event_staff_schedule_time_slot_path(object.event, object), toggle: 'modal', target: "#time-slot-edit-dialog"}
  end

  def ts_data
    ts = object
    starts = (ts.start_time.to_i - ts.start_time.beginning_of_day.to_i)/60
    ends = (ts.end_time.to_i - ts.end_time.beginning_of_day.to_i)/60

    data = {
      starts: starts,
      duration: ends - starts,
    }

    if ts.persisted?
      data.merge!({
        edit_path: h.edit_event_staff_schedule_grid_time_slot_path(object.event, object),
        update_path: h.event_staff_schedule_grid_time_slot_url(object.event, object),
        toggle: 'modal',
        target: '#grid-time-slot-edit-dialog'
      })
    end
    data
  end

  def display_title
    object.session_title || object.title
  end

  def display_presenter
    object.session_presenter || object.presenter
  end

  def display_track_name
    object.session_track_name || object.track_name
  end

  def display_description
    object.session_description || object.description
  end

  def preview_css
    'preview' unless object.persisted?
  end

  def filled_with_session?
    object.program_session.present?
  end

  def configured?
    object.persisted? && (display_title || display_presenter || display_track_name || display_description)
  end

  private

  def speaker_names(session)
    session.speakers.map(&:name).join(', ') if session
  end
end
