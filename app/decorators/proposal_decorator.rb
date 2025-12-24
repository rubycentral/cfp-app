class ProposalDecorator < Draper::Decorator
  decorates :proposal
  delegate_all
  decorates_association :speakers

  def speaker_state(small: false)
    speaker_state = if object.awaiting_confirmation?
      'Waiting for speaker confirmation'
    elsif state.include?('soft')
      Proposal.states[:submitted]
    else
      state
    end

    state_label(small: small, state: speaker_state)
  end

  def reviewer_state(small: false)
    reviewer_state = if state.include?('soft')
      Proposal.states[:submitted]
    else
      state
    end

    state_label(small: small, state: reviewer_state, show_confirmed: false)
  end

  def state
    if object.rejected?
      Proposal.states[:not_accepted]
    else
      Proposal.states[object.state.to_sym]
    end
  end

  def average_rating
    h.number_with_precision(object.average_rating, precision: 1) || ''
  end

  def session_format_name
    object.session_format.try(:name)
  end

  def track_name
    object.track.try(:name) || Track::NO_TRACK
  end

  def no_track_name_for_speakers
    "#{Track::NO_TRACK} - No Suggested Track"
  end

  def track_name_for_speakers
    object.track.try(:name) || no_track_name_for_speakers
  end

  def review_tags_labels
    h.safe_join(
      object.review_tags.map { |tag| h.content_tag :span, tag, class: 'label label-success label-compact' },
      "\n"
    )
  end

  def tags_labels
    h.safe_join(
      object.tags.map { |tag| h.content_tag :span, tag, class: 'label label-primary label-compact' },
      "\n"
    )
  end

  def review_tags_list
    object.review_tags.join(', ')
  end

  def speaker_name
    speaker ? speaker.name : ''
  end

  def speaker_names
    object.speakers.map(&:name).join(', ')
  end

  def speaker_emails
    object.speakers.map(&:email).join(', ')
  end

  def bio
    speaker ? speaker.bio : ''
  end

  def confirm_link
    h.link_to 'confirmation page',
      h.event_proposal_url(object.event, object, protocol: 'https')
  end

  def state_label(small: false, state: nil, show_confirmed: false)
    state ||= self.state

    classes = "label #{state_class(state)}"
    classes += ' label-mini' if small

    state += ' & confirmed' if proposal.confirmed? && show_confirmed

    h.content_tag :span, state, class: classes
  end

  def updated_in_words
    "#{h.time_ago_in_words(object.updated_by_speaker_at)} ago"
  end

  def created_in_words
    "#{h.time_ago_in_words(object.created_at)} ago"
  end

  def invitations_enabled?(user)
    object.has_speaker?(user) && !object.finalized?
  end

  private

  def speaker
    object.speakers.first
  end

  def state_class(state)
    case state
    when Proposal.states[:not_accepted]
      h.current_user.reviewer_for_event?(object.event) ? 'label-danger' : 'label-info'
    when Proposal.states[:soft_rejected]
      'label-danger'
    when Proposal.states[:soft_waitlisted], Proposal.states[:withdrawn]
      'label-warning'
    when Proposal.states[:accepted], Proposal.states[:soft_accepted]
      'label-success'
    else
      'label-default'
    end
  end
end
