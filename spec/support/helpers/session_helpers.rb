module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'user_password', with: password
      fill_in 'user_password_confirmation', with: confirmation
      click_button 'Sign up'
    end

    def signin(email, password)
      visit new_user_session_path
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      click_button 'Log in'
    end

    def forgot_password(email)
      visit new_user_session_path
      click_link 'Forgot your password?'
      fill_in 'user_email', with: email
      click_button 'Send me reset password instructions'
    end

  end
end
