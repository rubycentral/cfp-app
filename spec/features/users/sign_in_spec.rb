require 'rails_helper'
# Feature: Sign In
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign In', :devise do

  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot sign in if not registered' do
    signin('test@example.com', 'please123')
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'Email'
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'user can sign in with valid credentials' do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'user cannot sign in with wrong email' do
    user = FactoryBot.create(:user)
    signin('invalid@email.com', user.password)
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'Email'
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'user cannot sign in with wrong password' do
    user = FactoryBot.create(:user)
    signin(user.email, 'invalidpass')
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'Email'
  end

  # Scenario: Organizer User gets redirected to the events_path
  #   Given I exist as an organizer user
  #   And I am not signed in
  #   When I sign in
  #   Then I see see the events_path
  scenario 'organizer goes to the events_path' do
    organizer = create(:organizer)
    signin(organizer.email, organizer.password)
    expect(current_path).to eq(events_path)
  end

  # Scenario: reviewer User gets redirected to the events_path
  #   Given I exist as an reviewer user
  #   And I am not signed in
  #   When I sign in
  #   Then I see see the events_path
  scenario 'reviewer goes to the events_path' do
    reviewer = create(:reviewer)
    signin(reviewer.email, reviewer.password)
    expect(current_path).to eq(events_path)
  end

  # Scenario: Program Team User gets redirected to the events_path
  #   Given I exist as an program_team user
  #   And I am not signed in
  #   When I sign in
  #   Then I see see the events_path
  scenario 'program_team goes to the events_path' do
    program_team = create(:program_team)
    signin(program_team.email, program_team.password)
    expect(current_path).to eq(events_path)
  end

  # Scenario: Admin User gets redirected to the admin_events_path
  #   Given I exist as an admin user
  #   And I am not signed in
  #   When I sign in
  #   Then I see see the events_path
  scenario 'admin goes to the events_path' do
    admin = create(:admin)
    signin(admin.email, admin.password)
    expect(current_path).to eq(admin_events_path)
  end

  # Scenario: Speaker User gets redirected to the events page
  #   Given I exist as an speaker user
  #   And I am not signed in
  #   When I sign in
  #   Then I see the events_path
  scenario 'speaker with proposals goes to their proposals' do
    proposal = create(:proposal)
    speaker = create(:speaker)
    proposal.speakers << speaker
    user = speaker.user

    signin(user.email, user.password)
    expect(current_path).to eq(proposals_path)
    expect(page).to have_content("Signed in successfully")
  end

  # Scenario: Incomplete User gets redirected to the edit_profile_path
  #   Given I exist as an incomplete user
  #   And I am not signed in
  #   When I sign in
  #   Then I see see the edit_profile_path
  scenario 'incomplete goes to the edit_profile_path' do
    user = create(:user, name: nil)
    signin(user.email, user.password)
    expect(current_path).to eq(edit_profile_path)
  end


end
