require 'rails_helper'
# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'Sign out', type: :system do
  # Scenario: User signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario 'user signs out successfully', js: true do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).to have_content 'Signed in successfully.'

    find('.gravatar-container').click
    within('.dropdown-menu.show') { click_on 'Sign Out' }

    # Signing out is a Turbo-submitted DELETE followed by two redirects, which
    # a loaded CI runner does not always finish within Capybara's default wait.
    expect(page).to have_content 'Signed out successfully.', wait: 10
    expect(page).to have_no_content 'Signed in successfully.'
  end
end
