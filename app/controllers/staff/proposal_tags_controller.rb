class Staff::ProposalTagsController < Staff::ApplicationController
  before_action :enable_staff_event_subnav

  def edit
  end

  def update
    authorize @event, :update?
    @event.update!(proposal_tags_params)
    render :show
  end

  private

  def proposal_tags_params
    params.require(:event).permit(:valid_proposal_tags)
  end
end
