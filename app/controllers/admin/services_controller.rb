class Admin::ServicesController < Admin::ApplicationController

  def destroy
    if @user = User.find(params[:user_id])
      if @service = @user.services.where(id: params[:id]).first
        @service.destroy
      end
    end
    redirect_to edit_admin_user_url(@user), flash: {info: "Service was successfully destroyed."}
  end
end
