class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
    @minimum_password_length = User::PASSWORD_LENGTH.min
  end

  def create
    @user = User.new(sign_up_params)
    @user.pending_invite_email = session[:pending_invite_email]

    if @user.save
      if @user.confirmed?
        start_authenticated_session @user
        target = after_sign_in_path_for(@user)
        session.delete(:pending_invite_email)
        redirect_to target, notice: 'Welcome! You have signed up successfully.'
      else
        redirect_to root_path, notice: 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
      end
    else
      @minimum_password_length = User::PASSWORD_LENGTH.min
      render :new, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
