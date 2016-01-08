class PersonDecorator < ApplicationDecorator
  delegate_all

  def proposal_path(proposal)
    # it seems like calling any path helper throws a deprecation like the one below:
    # DEPRECATION WARNING: The method `reviewer_event_proposal_path` cannot be used here as a full URL is required. Use `reviewer_event_proposal_url` instead. (called from proposal_path at /app/decorators/person_decorator.rb:7)

    event = proposal.event
    if object.organizer_for_event?(event)
      h.reviewer_event_proposal_path(event, proposal)
    elsif object.reviewer_for_event?(event)
      h.reviewer_event_proposal_path(event, proposal)
    else
      h.proposal_path(event.slug, proposal)
    end
  end
end
