class Staff::ProgramSessionDecorator < ApplicationDecorator
  decorates_association :speakers
  delegate_all

  def state_label(large: false, state: nil)
    state ||= self.state

    classes = "label #{state_class(state)}"
    classes += ' label-large' if large

    h.content_tag :span, state, class: classes
  end

  def confirmation_notes_link
    return '' unless object.confirmation_notes?
    id = h.dom_id(object, 'notes')
    h.link_to '#', id: id, title: 'Confirmation notes', class: 'popover-trigger', role: 'button', tabindex: 0, data: {
        toggle: 'popover', content: object.confirmation_notes, target: "##{id}", placement: 'bottom', trigger: 'manual'} do
      h.content_tag(:i, '', class: 'fa fa-file')
    end
  end

  def state_class(state)
    case state
    when ProgramSession::LIVE
      'label-success'
    when ProgramSession::WAITLISTED
      'label-warning'
    when ProgramSession::DRAFT
      'label-default'
    when ProgramSession::DECLINED
      'label-danger'
    else
      'label-default'
    end
  end

  def track_name
    object.track_name || Track::NO_TRACK
  end

  def confirmed_status
    if (object.proposal.present? && object.proposal.confirmed_at.present?) || (object.proposal.nil? && object.state == ProgramSession::LIVE)
      h.content_tag(:i, '', class: 'fa fa-check')
    end
  end

  def abstract_markdown
    h.markdown(object.abstract)
  end

  def scheduled_for
    parts = []
    if object.time_slot
      ts = object.time_slot
      parts << ts.conference_day if ts.conference_day.present?
      parts << ts.start_time.to_s(:time) if ts.start_time.present?
      parts << ts.room.name if ts.room.present?
    end
    parts.join(', ')
  end

  def complete_video_url
    if object.video_url.include?("://")
      object.video_url
    else
      "http://#{object.video_url}"
    end
  end

  def complete_slides_url
    if object.slides_url.include?("://")
      object.slides_url
    else
      "http://#{object.slides_url}"
    end
  end
end
