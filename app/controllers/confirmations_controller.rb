class ConfirmationsController < ApplicationController
  allow_unauthenticated_access

  def show
    if (user = User.find_by_email_confirmation_token(params[:token] || params[:confirmation_token]))
      user.confirm!
      redirect_to new_user_session_path, notice: 'Your email address has been successfully confirmed.'
    else
      redirect_to new_user_confirmation_path, flash: {danger: 'Confirmation token is invalid or has expired.'}
    end
  end

  def new
    @user = User.new
  end

  def create
    email = params.dig(:user, :email).to_s
    user = User.find_by(unconfirmed_email: email) || User.find_by(email: email)

    if user.nil?
      @user = User.new(email: email).tap { it.errors.add(:email, :not_found, message: 'not found') }
      render :new, status: :unprocessable_entity
    elsif user.confirmed? && user.unconfirmed_email.blank?
      @user = user.tap { it.errors.add(:email, :already_confirmed, message: 'was already confirmed, please try signing in') }
      render :new, status: :unprocessable_entity
    else
      user.send_confirmation_instructions
      redirect_to new_user_session_path, notice: 'You will receive an email with instructions for how to confirm your email address in a few minutes.'
    end
  end
end
