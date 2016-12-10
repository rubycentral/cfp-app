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

  def score_for(person)
    person.rating_for(object).score
  end

  def review_tags
    object.review_tags.map { |tag|
      h.content_tag :span, tag, class: 'label label-success' }.join("\n").html_safe
  end

  def tags
    object.tags.map { |tag|
      h.content_tag :span, tag, class: 'label label-primary' }.join("\n").html_safe
  end

  def review_taggings
    object.review_tags.join(', ')
  end

  def speaker_name
    speaker && speaker.person ? speaker.name : ''
  end

  def speaker_names
    object.speakers.map {|s| s.name if s.person}.compact.join(', ')
  end

  def speaker_emails
    object.speakers.map {|s| s.name if s.person}.compact.join(', ')
  end

  def bio
    speaker ? speaker.bio : ''
  end

  def pitch
    h.markdown(object.pitch)
  end

  def details
    h.markdown(object.details)
  end

  def abstract
    h.markdown(object.abstract)
  end

  def withdraw_button
    h.link_to bang('Withdraw Proposal'),
      h.withdraw_proposal_path,
      method: :post,
      data: {
        confirm: 'This will remove your talk from consideration and send an ' +
                 'email to the event coordinator. Are you sure you want to do this?'
      },
      class: 'btn btn-warning',
      id: 'withdraw'
  end

  def confirm_link
    h.confirm_proposal_url(slug: object.event.slug, uuid: object)
  end

  def state_label(small: false, state: nil, show_confirmed: false)
    state ||= self.state

    classes = "label #{state_class(state)}"
    classes += ' status' unless small

    state += ' & confirmed' if proposal.confirmed? && show_confirmed

    h.content_tag :span, state, class: classes
  end

  def updated_in_words
    "updated #{h.time_ago_in_words(object.updated_by_speaker_at)} ago"
  end

  def created_in_words
    "created #{h.time_ago_in_words(object.created_at)} ago"
  end

  def title_input(form)
    form.input :title, placeholder: 'Title of the talk',
    maxlength: :lookup, input_html: { class: 'watched js-maxlength-alert' },
    hint: "Please limit your title to 60 characters or less."
  end

  def speaker_input(form)
    form.input :speaker, placeholder: 'Speaker Name'
  end

  def abstract_input(form)
    form.input :abstract, placeholder: 'What is your talk about?',
      maxlength: 1000, input_html: { class: 'watched js-maxlength-alert', rows: 5 },
      hint: 'Provide a concise description for the program limited to 600 characters or less.'
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
