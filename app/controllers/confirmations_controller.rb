class ConfirmationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_confirmation_path, alert: 'Try again later.' }

  def show
    if (user = User.find_by_email_confirmation_token(params[:token] || params[:confirmation_token]))
      begin
        user.confirm!
        redirect_to new_session_path, notice: 'Your email address has been successfully confirmed.'
      rescue ActiveRecord::RecordInvalid
        redirect_to new_confirmation_path, flash: {danger: "Confirmation failed: #{user.errors.full_messages.to_sentence}."}
      end
    else
      redirect_to new_confirmation_path, flash: {danger: 'Confirmation token is invalid or has expired.'}
    end
  end

  def new
    @user = User.new
  end

  def create
    email = params.dig(:user, :email).to_s
    user = User.find_by(unconfirmed_email: email) || User.find_by(email: email) if email.present?

    if user.nil?
      @user = User.new(email: email).tap { it.errors.add(:email, :not_found, message: 'not found') }
      render :new, status: :unprocessable_entity
    elsif user.confirmed? && user.unconfirmed_email.blank?
      @user = user.tap { it.errors.add(:email, :already_confirmed, message: 'was already confirmed, please try signing in') }
      render :new, status: :unprocessable_entity
    else
      user.send_confirmation_instructions
      redirect_to new_session_path, notice: 'You will receive an email with instructions for how to confirm your email address in a few minutes.'
    end
  end
end
