class TimeSlotDecorator < Draper::Decorator
  delegate_all

  def start_time
    object.start_time.try(:to_s, :time)
  end

  def end_time
    object.end_time.try(:to_s, :time)
  end

  def time_slot_id
    object.id
  end

  def row_data(buttons: false)
    row = [object.conference_day, start_time, end_time, linked_title,
           presenter, room_name, track_name, time_slot_id]

    row << action_links if buttons
    row
  end

  def row
    {id: object.id, values: row_data(buttons: true)}
  end

  def action_links
    [
      h.link_to('Edit',
                h.edit_event_staff_time_slot_path(object.event, object),
                class: 'btn btn-primary btn-xs',
                remote: true,
                data: {toggle: 'modal', target: "#time-slot-edit-dialog"}),

      h.link_to('Remove',
                h.event_staff_time_slot_path(object.event, object),
                method: :delete,
                data: {confirm: "Are you sure you want to remove this time slot?"},
                remote: true,
                class: 'btn btn-danger btn-xs')
    ].join("\n").html_safe
  end

  def unscheduled_program_sessions
    program_sessions = object.event.program_sessions.unscheduled

    if object.program_session
      program_sessions.unshift(object.program_session)
    end

    program_sessions.map do |ps|
      notes = ps.confirmation_notes || ''

      h.content_tag :option, ps.title, value: ps.id,
                    data: {'confirmation-notes' => notes}, selected: ps == object.program_session
    end.join.html_safe
  end

  def proposal_confirm_notes
    object.program_session.try(:proposal).try(:confirmation_notes)
  end

  def title
    if object.program_session.present?
      object.program_session.title
    else
      object.title
    end
  end

  def linked_title
    if object.program_session.present?
      h.link_to(object.program_session.title,
                h.event_staff_proposal_path(object.event, object.program_session.proposal))
    else
      object.title
    end
  end

  def presenter
    object.program_session.try(:proposal).try(:speaker_names) || object.presenter
  end

  def track_id
    object.program_session.try(:track_id)
  end

  def track_name
    object.program_session.try(:track).try(:name)
  end

  def room_name
    object.try(:room).try(:name)
  end

  def conference_wide_title
    title + ": " + room_name
  end

  def cell_data_attr
    {"time-slot-edit-path" => h.edit_event_staff_time_slot_path(object.event, object), toggle: 'modal', target: "#time-slot-edit-dialog"}
  end
end
