class Staff::ProgramSessionDecorator < Draper::Decorator
  decorates_association :speakers
  delegate_all

  def state_label(large: false, state: nil)
    state ||= self.state

    classes = "label #{state_class(state)}"
    classes += ' label-large' if large

    h.content_tag :span, object.state_before_type_cast, class: classes
  end

  def confirmation_notes_link
    return '' unless object.confirmation_notes?

    h.link_to h.event_staff_program_session_path(object.event, object) do
      h.content_tag(:i, '', class: 'bi bi-file-text')
    end
  end

  STATE_CLASSES = {
    live: 'label-success',
    draft: 'label-default',
    unconfirmed_accepted: 'label-info',
    unconfirmed_waitlisted: 'label-warning',
    confirmed_waitlisted: 'label-warning',
    declined: 'label-danger'
  }.with_indifferent_access

  def state_class(state)
    STATE_CLASSES[state] || 'label-default'
  end

  def track_name
    object.track_name || Track::NO_TRACK
  end

  def format_name
    object.session_format.name
  end

  def display_speakers
    object.speakers.pluck(:speaker_name).join(", ")
  end

  def ps_data
    data = {
      track_css: track_name.try(:parameterize),
      id: object.id,
      show_path: h.event_staff_schedule_grid_program_session_url(object.event.slug, object.id),
    }
    if object.time_slot
      data.merge!({
        scheduled: object.time_slot.id,
        unschedule_time_slot_path: h.event_staff_schedule_grid_time_slot_url(object.event, object.time_slot)
      })
    end
    data
  end

  def scheduled_for
    if object.time_slot
      ts = object.time_slot
      "Day #{ts.conference_day}" if ts.conference_day.present?
    end
  end

  def complete_video_url
    if object.video_url[/^https?:\/\//]
      object.video_url
    else
      "http://#{object.video_url}"
    end
  end

  def complete_slides_url
    if object.slides_url[/^https?:\/\//]
      object.slides_url
    else
      "http://#{object.slides_url}"
    end
  end
end
