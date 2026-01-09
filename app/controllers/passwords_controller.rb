class PasswordsController < ApplicationController
  include Authentication

  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
    render 'devise/passwords/new'
  end

  def create
    if (user = User.find_by(email: params[:user][:email]))
      PasswordsMailer.reset(user).deliver_later

      redirect_to new_user_session_path, notice: 'Password reset instructions sent (if user with that email address exists).'
    else
      @user = User.new.tap { it.errors.add(:email, :not_found) }

      render 'devise/passwords/new'
    end
  end

  def edit
    render 'devise/passwords/edit'
  end

  def update
    if @user.update(params.require(:user).permit(:password, :password_confirmation))
      redirect_to new_user_session_path, notice: 'Password has been reset.'
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
