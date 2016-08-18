class UserDecorator < ApplicationDecorator
  delegate_all

  def proposal_notification_path(proposal)
    event = proposal.event
    if proposal.has_speaker?(object)
      h.event_proposal_path(event, proposal)
    else
      h.event_staff_proposal_path(event, proposal)
    end
  end
end
