class Reviewer::ParticipantsController < Reviewer::ApplicationController
  respond_to :html, :json
  skip_before_filter :require_proposal

  def update
    participant = Participant.find(params[:id])
    participant.update(participant_params)

    flash[:info] = "You have successfully changed your participant."
    redirect_to :back
  end

  private

  def participant_params
    params.require(:participant).permit(:role, :notifications)
  end
end
