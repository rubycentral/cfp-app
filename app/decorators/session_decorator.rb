class SessionDecorator < Draper::Decorator
  delegate_all
  decorates_association :proposal

  def start_time
    object.start_time && object.start_time.to_s(:time)
  end

  def end_time
    object.end_time && object.end_time.to_s(:time)
  end

  def session_id
    object.id
  end

  def proposal_id
    if proposal
      "prop_#{proposal.id}"
    else
      ""
    end
  end

  def row_data(buttons: false)
    row = [object.conference_day, start_time, end_time, linked_title,
           presenter, room_name, track_name, session_id]

    row << session_buttons if buttons
    row
  end

  def row
    {id: object.id, values: row_data(buttons: true)}
  end

  def session_buttons
    [
      h.link_to('Edit',
                h.edit_organizer_event_session_path(object.event, object),
                class: 'btn btn-primary btn-xs',
                remote: true,
                data: {toggle: 'modal', target: "#session-edit-dialog"}),

      h.link_to('Remove',
                h.organizer_event_session_path(object.event, object),
                method: :delete,
                data: {confirm: "Are you sure you want to remove this session?"},
                remote: true,
                class: 'btn btn-danger btn-xs')
    ].join("\n").html_safe
  end

  def available_proposals
    proposals = object.event.proposals.available

    if object.proposal
      # Add currently selected proposal to list
      proposals.unshift(object.proposal)
    end

    proposals.map do |p|
      notes = p.confirmation_notes || ''

      h.content_tag :option, p.title, value: p.id,
                    data: {'confirmation-notes' => notes}, selected: p == object.proposal
    end.join.html_safe
  end

  def proposal_confirm_notes
    object.proposal && object.proposal.confirmation_notes
  end

  def title
    if object.proposal.present?
      object.proposal.title
    else
      object.title
    end
  end

  def linked_title
    if object.proposal.present?
      h.link_to(object.proposal.title,
                h.organizer_event_proposal_path(object.event, object.proposal))
    else
      object.title
    end
  end

  def presenter
    proposal.present? ? proposal.speaker_names : object.presenter
  end

  def room_name
    object.room && object.room.name
  end

  def track_name
    object.track && object.track.name
  end

  def conference_wide_title
    title + ": " + room_name
  end

  def cell_data_attr
    {"session-edit-path" => h.edit_organizer_event_session_path(object.event, object), toggle: 'modal', target: "#session-edit-dialog"}
  end
end