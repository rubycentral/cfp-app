class ProposalDecorator < ApplicationDecorator
  include Proposal::State
  decorates :proposal
  delegate_all
  decorates_association :speakers

  def public_state(small: false)
    public_state = if state.include?('soft')
      SUBMITTED
    else
      state
    end

    state_label(small: small, state: public_state)
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
    object.track.try(:name) || 'General'
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
    h.link_to bang('Withdraw Proposal'),
      h.withdraw_event_proposal_path(uuid: object, event_slug: object.event.slug),
      method: :post,
      data: {
        confirm: 'This will remove your talk from consideration and send an ' +
                 'email to the event coordinator. Are you sure you want to do this?'
      },
      class: 'btn btn-warning',
      id: 'withdraw'
  end

  def confirm_link
    h.link_to 'confirmation page',
      h.confirm_event_proposal_url(event_slug: object.event.slug, uuid: object)
  end

  def state_label(small: false, state: nil, show_confirmed: false)
    state ||= self.state

    classes = "label #{state_class(state)}"
    classes += ' label-mini' if small

    # state += ' & confirmed' if proposal.confirmed? && show_confirmed

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
      maxlength: 605, input_html: { class: 'watched js-maxlength-alert', rows: 5 },
      hint: 'A concise, engaging description for the public program. Limited to 600 characters.'#, popover_icon: { content: tooltip }
  end

  def standalone_track_select
    h.select_tag :track, h.options_for_select(track_options, object.track_id), include_blank: 'General – No Suggested Track',
               class: 'proposal-track-select', data: { target_path: h.event_staff_program_proposal_update_track_path(object.event, object) }
  end

  def track_options
    @track_options ||= object.event.tracks.map {|t| [t.name, t.id]}
  end

  private

  def speaker
    object.speakers.first
  end

  def state_class(state)
    case state
    when NOT_ACCEPTED
      if h.reviewer?
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
