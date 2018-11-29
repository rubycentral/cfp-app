class ProposalDecorator < ApplicationDecorator
  include Proposal::State
  decorates :proposal
  delegate_all
  decorates_association :speakers

  def speaker_state(small: false)
    speaker_state = if object.awaiting_confirmation?
      'Waiting for speaker confirmation'
    elsif state.include?('soft')
      SUBMITTED
    else
      state
    end

    state_label(small: small, state: speaker_state)
  end

  def reviewer_state(small: false)
    reviewer_state = if state.include?('soft')
      SUBMITTED
    else
      state
    end

    state_label(small: small, state: reviewer_state, show_confirmed: false)
  end

  def state
    current_state = object.state
    if current_state == REJECTED
      NOT_ACCEPTED
    else
      current_state
    end
  end

  def average_rating
    h.number_with_precision(object.average_rating, precision: 1) || ''
  end

  def score_for(user)
    user.rating_for(object).score
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
    object.review_tags.map { |tag|
      h.content_tag :span, tag, class: 'label label-success label-compact' }.join("\n").html_safe
  end

  def tags_labels
    object.tags.map { |tag|
      h.content_tag :span, tag, class: 'label label-primary label-compact' }.join("\n").html_safe
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

  def pitch_markdown
    h.markdown(object.pitch)
  end

  def details_markdown
    h.markdown(object.details)
  end

  def abstract_markdown
    h.markdown(object.abstract)
  end

  def withdraw_button
    h.link_to h.bang('Withdraw Proposal'),
      h.withdraw_event_proposal_path(uuid: object, event_slug: object.event.slug),
      method: :post,
      data: {
        confirm: 'This will remove your talk from consideration and send an ' +
                 'email to the event coordinator. Are you sure you want to do this?'
      },
      class: 'btn btn-warning',
      id: 'withdraw'
  end

  def confirm_button
    h.link_to 'Confirm',
              h.confirm_event_proposal_path(uuid: object, event_slug: object.event.slug),
              method: :post,
              class: 'btn btn-success'
  end

  def decline_button
    h.link_to h.bang('Decline'),
              h.decline_event_proposal_path(uuid: object, event_slug: object.event.slug),
              method: :post,
              data: {
                  confirm: 'This will remove your talk from consideration and notify the event staff. Are you sure you want to do this?'
              },
              class: 'btn btn-warning'
  end

  def confirm_link
    h.link_to 'confirmation page',
      h.event_proposal_url(object.event, object)
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

  def title_input(form)
    form.input :title,
    autofocus: true,
    maxlength: :lookup, input_html: { class: 'watched js-maxlength-alert' },
    hint: "Publicly viewable title. Ideally catchy, interesting, essence of the talk. Limited to 60 characters."
  end

  def speaker_input(form)
    form.input :speaker
  end

  def abstract_input(form, tooltip = "Proposal Abstract")
    form.input :abstract,
      maxlength: 1005, input_html: { class: 'watched js-maxlength-alert', rows: 5 },
      hint: 'A concise, engaging description for the public program. Limited to 600 characters.'#, popover_icon: { content: tooltip }
  end

  def standalone_track_select(tooltip)
    h.simple_form_for :proposal, remote: true do |f|
      f.input :track,
        required: false,
        label_html: { class: 'info-item-heading' },
        collection: track_options,
        include_blank: Track::NO_TRACK,
        selected: object.track_id,
        id: 'track',
        input_html: {
          class: 'proposal-track-select form-control select',
          data: {
            target_path: h.event_staff_program_proposal_update_track_path(object.event, object)
          },
        },
        popover_icon: { content: tooltip }
    end
  end

  def standalone_format_select(tooltip)
    h.simple_form_for :proposal, remote: true do |f|
      f.input :format,
        required: false,
        label_html: { class: 'info-item-heading' },
        collection: format_options,
        include_blank: Track::NO_TRACK,
        selected: object.session_format_id,
        id: 'track',
        input_html: {
          class: 'proposal-format-select form-control select',
          data: {
            target_path: h.event_staff_program_proposal_update_session_format_path(object.event, object)
          },
        },
        popover_icon: { content: tooltip }
    end
  end

  def track_options
    @track_options ||= object.event.tracks.map { |t| [t.name, t.id] }.sort
  end

  def format_options
    @format_options ||= object.event.session_formats.map { |sf| [sf.name, sf.id] }.sort
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
    when NOT_ACCEPTED
      if h.current_user.reviewer_for_event?(object.event)
        'label-danger'
      else
        'label-info'
      end
    when SOFT_REJECTED
      'label-danger'
    when SOFT_WAITLISTED
      'label-warning'
    when WITHDRAWN
      'label-warning'
    when ACCEPTED
      'label-success'
    when SOFT_ACCEPTED
      'label-success'
    else
      'label-default'
    end
  end

end
