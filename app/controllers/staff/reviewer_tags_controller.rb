class Staff::ReviewerTagsController < Staff::ApplicationController
  before_action :enable_staff_event_subnav

  def edit
  end

  def update
    authorize @event, :update?
    @event.update!(reviewer_tags_params)
    render :show
  end

  private

  def reviewer_tags_params
    params.require(:event).permit(:valid_review_tags)
  end
end
