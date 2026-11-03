class SessionsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: 'Try again later.' }

  def new
  end

  def create
    user = User.authenticate_by(email: session_params[:email], password: session_params[:password]) if session_params[:password].present?

    if user.nil?
      redirect_to new_session_path, flash: {danger: 'Invalid Email or password.'}
    elsif !user.confirmed?
      redirect_to new_session_path, flash: {danger: 'You have to confirm your email address before continuing.'}
    else
      start_authenticated_session user
      redirect_to after_sign_in_path_for(user), notice: 'Signed in successfully.'
    end
  end

  def destroy
    terminate_session if authenticated?
    redirect_to root_path, notice: 'Signed out successfully.'
  end

  private

  def session_params
    params.fetch(:user, {}).permit(:email, :password)
  end
end
