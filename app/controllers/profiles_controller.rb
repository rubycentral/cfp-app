class ProfilesController < ApplicationController
  before_filter :require_user

  def edit
    current_user.valid?
  end

  def update
    if current_user.update_attributes(user_params)

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
