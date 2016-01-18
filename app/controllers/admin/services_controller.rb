class Admin::ServicesController < Admin::ApplicationController

  def destroy
    if @person = Person.find(params[:person_id])
      if @service = @person.services.where(id: params[:id]).first
        @service.destroy
      end
    end
    redirect_to edit_admin_person_url(@person), flash: {info: "Service was successfully destroyed."}
  end
end