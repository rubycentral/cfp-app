class UserDecorator < ApplicationDecorator
  delegate_all

  def proposal_url(proposal)
    event = proposal.event
    if model.staff_for? event
      h.event_staff_proposal_url(event, proposal)
    else
      h.event_proposal_url(event, proposal)
    end

  end
end
