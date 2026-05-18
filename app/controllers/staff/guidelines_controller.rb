class Staff::GuidelinesController < Staff::ApplicationController
  before_action :enable_staff_event_subnav

  def show
  end

  def edit
  end

  def update
    authorize @event, :update?
    if @event.update(params.require(:event).permit(:guidelines))
      redirect_to event_staff_guidelines_path
    else
      flash[:danger] = "There was a problem saving your guidelines; please review the form for issues and try again."
      render :edit, status: :unprocessable_entity
    end
  end
end
