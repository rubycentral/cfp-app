class SpeakersController < ApplicationController
  before_filter :require_user



  def destroy
    speaker = Speaker.find_by!(id: params[:id])

    proposal = speaker.proposal
    speaker.destroy

    flash[:info] = "You've withdrawn from this proposal."
    redirect_to proposal_url(slug: proposal.event.slug, uuid: proposal)
  end
end
