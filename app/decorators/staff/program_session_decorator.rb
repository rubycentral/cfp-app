class Staff::ProgramSessionDecorator < ApplicationDecorator
  decorates_association :speakers
  delegate_all

  def track_name
    object.track.try(:name) || 'General'
  end

  def speaker_names
    object.speakers.map(&:name).join(', ')
  end

  def speaker_emails
    object.speakers.map(&:email).join(', ')
  end

  def session_format_name
    object.session_format.try(:name)
  end

  def state_label(large: false, state: nil)
    state ||= self.state

    classes = "label #{state_class(state)}"
    classes += ' label-large' if large

    h.content_tag :span, state, class: classes
  end

  def state_class(state)
    case state
    when ProgramSession::ACTIVE
      'label-success'
    when ProgramSession::WAITLISTED
      'label-warning'
    when ProgramSession::INACTIVE
      'label-default'
    else
      'label-default'
    end
  end

  def abstract_markdown
    h.markdown(object.abstract)
  end

  def scheduled_for
    day = object.time_slot.conference_day
    from = object.time_slot.start_time.to_s(:time)
    to = object.time_slot.end_time.to_s(:time)
    "Day #{day}, #{from} - #{to}"
  end
end
