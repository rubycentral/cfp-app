require 'rails_helper'
# Feature: forgot password
#   As a user
#   I want to forgot password
#   So I can visit protected areas of the site
feature 'Forgot Password', :devise do

  # Scenario: User cannot forgot password if not registered
  #   Given I do not exist as a user
  #   When I forgot password with valid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot forgot password if not registered', js: true do
    forgot_password('test@example.com')
    expect(page).to have_content 'Email * ' + I18n.t('errors.messages.not_found')
  end

  # Scenario: User can forgot password with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I forgot password with valid credentials
  #   Then I see a success message
  scenario 'user can forgot password with valid credentials', js: true do
    user = FactoryBot.create(:user)
    forgot_password(user.email)
    expect(page).to have_content I18n.t 'devise.passwords.send_instructions'
  end

  # Scenario: User cannot forgot password with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I forgot password with a wrong email
  #   Then I see an invalid email message
  scenario 'user cannot forgot password with wrong email', js: true do
    user = FactoryBot.create(:user)
    forgot_password('invalid@email.com')
    expect(page).to have_content 'Email * ' + I18n.t('errors.messages.not_found')
  end

end
