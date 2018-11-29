require 'rails_helper'

feature 'User Profile' do
  let(:user) { create(:user) }

  before { login_as(user) }

  scenario "A user can save their bio" do
    visit(edit_profile_path)
    fill_in('Bio', with: 'I am awesome')
    click_button 'Save'

    user.reload
    expect(user.bio).to eq('I am awesome')
  end

  scenario "A user can edit their bio" do
    visit(edit_profile_path)
    fill_in('Bio', with: 'I am awesome')
    click_button 'Save'

    visit(edit_profile_path)
    fill_in('Bio', with: 'I am even more awesome')
    click_button 'Save'

    user.reload
    expect(user.bio).to eq('I am even more awesome')
  end

  scenario "A user attempts to save their bio without email", js: true do
    visit(edit_profile_path)
    fill_in('Email', with: '')
    click_button 'Save'
    expect(page).to have_content("Unable to save profile. Please correct the following: Email can't be blank")
  end

  scenario 'A user updates their event email preference' do
    teammate = create(:teammate, role: 'organizer', user: user, state: Teammate::ACCEPTED)
    visit(event_path(teammate.event))
    visit(edit_profile_path)
    choose(Teammate::NOTIFICATION_PREFERENCES[Teammate::MENTIONS])
    click_button 'Save'
    click_link 'Dashboard'
    click_link 'Team'
    expect(page).to have_content(Teammate::NOTIFICATION_PREFERENCES[Teammate::MENTIONS])
  end
end
