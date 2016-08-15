class InvitationDecorator < ApplicationDecorator
  delegate_all
  decorates_association :proposal

  STATE_LABEL_MAP = {
    Invitation::State::PENDING => 'label-default',
    Invitation::State::DECLINED => 'label-danger',
    Invitation::State::ACCEPTED => 'label-success'
  }

  def decline_button(small: false)
    classes = 'btn btn-danger'
    classes += ' btn-xs' if small

    h.link_to 'Decline',
      h.decline_invitation_path(object.slug),
      class: classes,
      data: { confirm: 'Are you sure you want to decline this invitation?' }
  end

  def accept_button(small: false)
    classes = 'btn btn-success'
    classes += ' btn-xs' if small

    h.link_to 'Accept',
      h.accept_invitation_path(object.slug),
      class: classes
  end

  def state_label
    h.content_tag :span, object.state,
      class: "label #{STATE_LABEL_MAP[object.state]}"
  end
end
