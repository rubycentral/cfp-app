class Reviewer::EventTeammatesController < Reviewer::ApplicationController
  respond_to :html, :json
  skip_before_filter :require_proposal

  def update
    event_teammate = EventTeammate.find(params[:id])
    event_teammate.update(event_teammate_params)

    flash[:info] = "You have successfully changed your event_teammate."
    redirect_to :back
  end

  private

  def event_teammate_params
    params.require(:event_teammate).permit(:role, :notifications)
  end
end
