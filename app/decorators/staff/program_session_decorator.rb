class Staff::ProgramSessionDecorator < ApplicationDecorator
  include Proposal::State
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
    session_format.name
  end

  def state_label(large: false, state: nil, show_confirmed: false)
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

  def scheduled?
    time_slot.present?
  end

  def track_name
    track.name
  end

  def session_format_name
    session_format.name
  end
end
