class PersonDecorator < ApplicationDecorator
  delegate_all

  def proposal_path(proposal)
    event = proposal.event
    if object.organizer_for_event?(event)
      h.reviewer_event_proposal_url(event, proposal)
    elsif object.reviewer_for_event?(event)
      h.reviewer_event_proposal_url(event, proposal)
    else
      h.proposal_url(event.slug, proposal)
    end
  end
end
