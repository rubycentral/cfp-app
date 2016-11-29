class Staff::ProposalDecorator < ProposalDecorator
  decorates :proposal

  def update_state_link(new_state)
    if new_state == object.state
      h.content_tag :span, new_state, class: 'disabled-state'
    else
      h.link_to new_state, update_state_path(new_state), method: :post
    end
  end

  def state_buttons(states: nil, show_finalize: true, show_confirm_for_speaker: false, small: false)
    btns = buttons.map do |text, state, btn_type, hidden|
      if states.nil? || states.include?(state)
        state_button(text, update_state_path(state),
          hidden: hidden,
          type: btn_type,
          small: small)
      end
    end

    btns << reset_state_button
    btns << finalize_state_button if show_finalize
    btns << confirm_for_speaker_button if show_confirm_for_speaker

    btns.join("\n").html_safe
  end

  def small_state_buttons
    state_buttons(
        states: [ SOFT_ACCEPTED, SOFT_WAITLISTED, SOFT_REJECTED, SUBMITTED ],
        show_finalize: false,
        small: true
    )
  end

  def title_link_for_review
    h.link_to h.truncate(object.title, length: 45),
              h.event_staff_proposal_path(object.event, object)
  end

  def title_link
    h.link_to h.truncate(object.title, length: 45),
              h.event_staff_program_proposal_path(object.event, object)
  end

  def standard_deviation
    h.number_with_precision(object.standard_deviation, precision: 3)
  end

  def delete_button
    h.button_to h.event_staff_program_proposal_path,
      method: :delete,
      data: {
        confirm:
          'This will delete this talk. Are you sure you want to do this? ' +
          'It can not be undone.'
      },
      class: 'btn btn-danger navbar-btn',
      id: 'delete' do
        bang('Delete Proposal')
      end
  end

  def created_at
    object.created_at.to_s(:short)
  end

  def updated_at
    object.updated_at.to_s(:short)
  end

  def comment_count
    proposal.internal_comments.size + proposal.public_comments.size
  end

  def internal_comments_style
    object.was_rated_by_user?(h.current_user) ? nil : "display: none;"
  end

  private

  def state_button(text, path, opts = {})
    opts = { method: :post, remote: :true, type: 'btn-default', hidden: false }.merge(opts)

    opts[:class] = "#{opts[:class]} btn #{opts[:type]} " + (opts[:hidden] ? 'hidden' : '')
    opts[:class] += opts[:small] ? ' btn-xs' : ' btn-sm'
    h.link_to(text, path, opts)
  end

  def finalize_state_button
    state_button('Finalize State',
                 h.event_staff_program_proposal_finalize_path(object.event, object),
                 data: {
                   confirm:
                     'Finalizing the state will prevent any additional state changes, ' +
                     'and emails will be sent to all speakers. Are you sure you want to continue?'
                 },
                 type: 'btn-warning',
                 hidden: finalize_button_hidden?,
                 remote: false,
                 id: 'finalize')
  end

  def reset_state_button
    state_button('Reset Status', update_state_path(SUBMITTED),
                 data: object.finalized? ? {
                     confirm:
                         "This proposal's status has been finalized. Proceed with status reset?"
                 } : {},
                 type: 'btn-default',
                 hidden: reset_button_hidden?)
  end

  def confirm_for_speaker_button
    return if confirm_for_speaker_button_hidden?

    h.link_to 'Confirm for Speaker',
            h.confirm_for_speaker_event_staff_program_proposal_path(slug: proposal.event.slug, uuid: proposal),
            method: :post,
            class: "btn btn-primary btn-sm"
  end

  def update_state_path(state)
    h.event_staff_program_proposal_update_state_path(object.event, object, new_state: state)
  end

  def buttons
    [
      [ 'Accept', SOFT_ACCEPTED, 'btn-success', !object.draft?  ],
      [ 'Waitlist', SOFT_WAITLISTED, 'btn-warning', !object.draft? ],
      [ 'Reject', SOFT_REJECTED, 'btn-danger', !object.draft? ]
    ]
  end

  def finalize_button_hidden?
    !h.policy(object).finalize? || object.draft? || object.finalized?
  end

  def reset_button_hidden?
    object.draft? || object.confirmed? || !h.policy(proposal).update_state? ||
      (object.finalized? && !h.policy(proposal).update_finalized_state?)
  end

  def confirm_for_speaker_button_hidden?
    !(object.awaiting_confirmation? && h.policy(object).confirm_for_speaker?)
  end
end
