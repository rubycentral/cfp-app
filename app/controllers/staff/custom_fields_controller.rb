class Staff::CustomFieldsController < Staff::ApplicationController
  before_action :enable_staff_event_subnav

  def edit
  end

  def update
    authorize @event, :update?
    @event.update!(custom_fields_params)
    render :show
  end

  private

  def custom_fields_params
    params.require(:event).permit(:custom_fields_string)
  end
end
