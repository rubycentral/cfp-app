class ProfilesController < ApplicationController
  before_filter :require_user

  def edit
    unless current_user.complete?
      flash.now[:danger] = "Please make sure your name and email address are present and correct."
    end
  end

  def update
    if current_user.update_attributes(user_params) && current_user.complete?
      current_user.assign_open_invitations if session[:need_to_complete]

      if current_user.unconfirmed_email.present?
        flash[:danger] = I18n.t("devise.registrations.update_needs_confirmation")
      else
        flash[:info] = I18n.t("devise.registrations.updated")
      end

      redirect_to (session.delete(:target) || root_url)
    else
      flash.now[:danger] = "Unable to save profile. Please correct the following: #{current_user.errors.full_messages.join(', ')}."
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:bio, :gender, :ethnicity, :country, :name, :email, :password, :password_confirmation)
  end
end
