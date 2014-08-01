class PersonDecorator < ApplicationDecorator
  delegate_all

  def proposal_path(proposal)
    event = proposal.event

    if object.reviewer_for_event?(event)
      h.reviewer_event_proposal_path(event, proposal)
    else
      h.proposal_path(event.slug, proposal)
    end
  end
end
