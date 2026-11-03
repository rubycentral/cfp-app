class ConfirmationsMailer < ApplicationMailer
  def confirmation_instructions(user)
    @user = user
    @email = user.unconfirmed_email || user.email
    @token = user.email_confirmation_token

    mail subject: 'Confirmation instructions', to: @email
  end
end
