class InvitationDecorator < ApplicationDecorator
  delegate_all

  STATE_LABEL_MAP = {
    Invitation::State::PENDING => 'label-default',
    Invitation::State::REFUSED => 'label-danger',
    Invitation::State::ACCEPTED => 'label-success'
  }

  def refuse_button(small: false)
    classes = 'btn btn-danger'
    classes += ' btn-xs' if small

    h.link_to 'Refuse',
      h.refuse_invitation_path(invitation_slug: object.slug),
      method: :post,
      class: classes,
      data: { confirm: 'Are you sure you want to refuse this invitation?' }
  end

  def accept_button(small: false)
    classes = 'btn btn-success'
    classes += ' btn-xs' if small

    h.link_to 'Accept',
      h.accept_invitation_path(invitation_slug: object.slug),
      method: :post,
      class: classes
  end

  def state_label
    h.content_tag :span, object.state,
      class: "label #{STATE_LABEL_MAP[object.state]}"
  end
end
