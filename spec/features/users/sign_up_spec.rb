require 'rails_helper'
# Feature: Sign Up
#   As a user
#   I want to sign Up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise do

  # Scenario: User cannot sign up if no password
  #   Given I do not exist as a user
  #   When I sign up with empty credentials
  #   Then I see an empty credentials message
  scenario 'user cannot sign up with empty password' do
    sign_up_with('test@example.com', '', '')
    expect(page).to have_content "Password *can't be blank"
  end

  # Scenario: User cannot sign up if invalid email
  #   Given I do not exist as a user
  #   When I sign up with invalid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot sign up with invalid email' do
    sign_up_with('test', '12341234', '12341234')
    expect(page).to have_content "Email *is invalid"
  end

  # Scenario: User cannot sign up if no email
  #   Given I do not exist as a user
  #   When I sign up with invalid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot sign up with an empty email' do
    sign_up_with('', '12341234', '12341234')
    expect(page).to have_content "Email *can't be blank"
  end

  # Scenario: User cannot sign up if no email
  #   Given I do not exist as a user
  #   When I sign up with invalid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot sign up with invalid password' do
    sign_up_with('test@example.com', '1234', '1234')
    expect(page).to have_content "Password *is too short"
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'user can sign up with valid credentials' do
    user = build(:user)
    sign_up_with(user.email, user.password, user.password)
    expect(page).to have_content I18n.t('devise.registrations.signed_up_but_unconfirmed')
  end

end
