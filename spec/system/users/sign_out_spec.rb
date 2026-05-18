require 'rails_helper'
# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'Sign out', :devise, type: :system do
  # Scenario: User signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario 'user signs out successfully', js: true do
    skip 'Too flaky'

    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).to have_content 'Signed in successfully.'

    find('.gravatar-container').click

    find('.dropdown-menu').find('a', text: 'Sign Out').click

    expect(page).to have_no_content 'Signed in successfully.'
    expect(page).to have_content 'Signed out successfully.'
  end
end
