class UserDecorator < ApplicationDecorator
  delegate_all

  def proposal_path(proposal)
    event = proposal.event
    if model.staff_for? event
      h.event_staff_proposal_path(event, proposal)
    else
      h.event_proposal_path(event, proposal)
    end

  end
end
