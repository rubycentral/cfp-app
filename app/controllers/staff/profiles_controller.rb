class Staff::ProfilesController < Staff::ApplicationController

  def edit
    @user = Speaker.find(params[:id]).user
  end

  def update
    @user = Speaker.find(params[:id]).user
    if @user.update(user_params)
      redirect_to event_staff_program_speakers_url(event)
    else
      if @user.email == ""
        @user.errors[:email].clear
        @user.errors[:email] = " can't be blank"
      end
      flash.now[:danger] = "Unable to save profile. Please correct the following: #{@user.errors.full_messages.join(', ')}."
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:bio, :gender, :ethnicity, :country, :name, :email)
  end
end

