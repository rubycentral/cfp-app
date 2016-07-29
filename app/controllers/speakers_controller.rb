class SpeakersController < ApplicationController
  before_action :require_user

  def destroy
    speaker = Speaker.find_by!(id: params[:id])

    proposal = speaker.proposal
    speaker.destroy

    if current_user.id == speaker.user_id
      flash[:info] = "You have withdrawn from #{proposal.title}."
      redirect_to root_path
    else
      flash[:info] = "#{speaker.email} has been withdrawn from #{proposal.title}."
      redirect_to event_proposal_path(event_slug: proposal.event.slug, uuid: proposal)
    end
  end
end
