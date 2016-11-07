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
    parts = []
    if object.time_slot
      ts = object.time_slot
      parts << ts.conference_day if ts.conference_day.present?
      parts << ts.start_time.to_s(:time) if ts.start_time.present?
      parts << ts.room.name if ts.room.present?
    end
    parts.join(', ')
  end
end
