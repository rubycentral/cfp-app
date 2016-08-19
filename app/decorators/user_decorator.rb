class UserDecorator < ApplicationDecorator
  delegate_all

  def proposal_notification_url(proposal)
    event = proposal.event
    if proposal.has_speaker?(object)
      h.event_proposal_url(event, proposal)
    else
      h.event_staff_proposal_url(event, proposal)
    end
  end
end
