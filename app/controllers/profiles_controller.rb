class ProfilesController < ApplicationController
  before_filter :require_user

  def edit
    unless current_user.complete?
      flash.now[:danger] = "Please make sure your name and email address are present and correct."
    end
  end

  def update
    if current_user.update_attributes(person_params) && current_user.complete?
      current_user.assign_open_invitations if session[:need_to_complete]
      redirect_to (session.delete(:target) || root_path), info: "We've updated your profile. Thanks!"
    else
      if current_user.email == ""
        current_user.errors[:email].clear
        current_user.errors[:email] = " can't be blank"
      end
      flash.now[:danger] = "Unable to save profile. Please correct the following: #{current_user.errors.full_messages.join(', ')}."
      render :edit
    end
  end

  private

  def person_params
    params.require(:person).permit(:bio, :gender, :ethnicity, :country, :name, :email)
  end
end
