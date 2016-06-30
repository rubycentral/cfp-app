class UserDecorator < ApplicationDecorator
  delegate_all

  def proposal_path(proposal)
    event = proposal.event
    h.event_staff_proposal_path(event, proposal)
  end
end
