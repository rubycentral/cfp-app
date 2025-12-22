class ProfilesController < ApplicationController
  before_action :require_user

  def show
    redirect_to edit_profile_path
  end

  def edit
    current_user.valid?
    flash.now[:warning] = incomplete_profile_msg unless current_user.complete?
  end

  def update
    if current_user.update(user_params)

      if current_user.unconfirmed_email.present?
        flash[:danger] = I18n.t("devise.registrations.update_needs_confirmation")
      else
        flash[:info] = I18n.t("devise.registrations.updated")
      end

      redirect_to (session.delete(:target) || root_url)
    else
      flash.now[:danger] = "Unable to save profile. Please correct the following: #{current_user.errors.full_messages.join(', ')}."
      render :edit, status: :unprocessable_entity
    end
  end

  def notifications
  end

  def update_notifications
    if current_user.update(notifications_params)
      flash[:info] = 'Notification preferences updated.'
      redirect_to notifications_profile_path
    else
      render :notifications, status: :unprocessable_entity
    end
  end

  def merge
    @legacy_user = User.find_by(id: session[:pending_merge_user_id])
    @provider = session[:pending_merge_provider]

    unless @legacy_user && @provider
      redirect_to edit_profile_path
    end
  end

  def confirm_merge
    legacy_user = User.find_by(id: session[:pending_merge_user_id])
    provider = session[:pending_merge_provider]
    uid = session[:pending_merge_uid]

    unless legacy_user && provider && uid
      flash[:danger] = 'Merge session expired. Please try again.'
      redirect_to edit_profile_path and return
    end

    current_user.merge_from!(legacy_user)
    current_user.identities.create!(provider: provider, uid: uid)

    session.delete(:pending_merge_user_id)
    session.delete(:pending_merge_provider)
    session.delete(:pending_merge_uid)

    flash[:info] = "Successfully merged accounts and connected #{Identity::PROVIDER_NAMES[provider]}."
    redirect_to edit_profile_path
  end

  private

  def user_params
    params.require(:user).permit(:bio, :gender, :ethnicity, :country, :name,
                                 :email, :password, :password_confirmation)
  end

  def notifications_params
    params.require(:user).permit(teammates_attributes: [:id, :notification_preference])
  end

  def incomplete_profile_msg
    if profile_errors = current_user.profile_errors
      msg = 'Your profile is incomplete. Please correct the following: '.html_safe
      msg << profile_errors.full_messages.to_sentence << '.'
    end
  end
end
