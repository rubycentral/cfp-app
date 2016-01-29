class Reviewer::ParticipantsController < Reviewer::ApplicationController
  respond_to :html, :json
  skip_before_filter :require_proposal

  def update
    participant = Participant.find(params[:id])
    participant.update(participant_params)

    flash[:info] = "You have successfully changed your notifications."
    redirect_to reviewer_event_url(@event)
  end

  private

  def participant_params
    params.require(:participant).permit(:role, :notifications)
  end
end
