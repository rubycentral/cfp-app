require 'rails_helper'

feature 'User Profile', type: :system do
  let(:user) { create(:user) }

  before { login_as(user) }

  scenario "A user can save their bio" do
    visit(edit_profile_path)
    fill_in('Bio', with: 'I am awesome')
    click_button 'Save', match: :first

    user.reload
    expect(user.bio).to eq('I am awesome')
  end

  scenario "A user can edit their bio" do
    visit(edit_profile_path)
    fill_in('Bio', with: 'I am awesome')
    click_button 'Save', match: :first

    visit(edit_profile_path)
    fill_in('Bio', with: 'I am even more awesome')
    click_button 'Save', match: :first

    user.reload
    expect(user.bio).to eq('I am even more awesome')
  end

  scenario "A user attempts to save their bio without email", js: true do
    visit(edit_profile_path)
    fill_in('Email', with: '')
    all('button', text: 'Save').last.click
    expect(page).to have_content("Unable to save profile. Please correct the following: Email can't be blank")
  end

  context 'when the profile is incomplete' do
    let(:lead_in) { 'Your profile is incomplete. Please correct the following:' }
    let(:trailing) { '.' }

    def visit_page
      visit edit_profile_path
    end

    it_behaves_like 'an incomplete profile warning'

    it 'shows no warning once the profile is complete' do
      visit edit_profile_path
      expect(page).not_to have_text(lead_in)
    end
  end

  scenario 'mentions the review committee only while a live event is blind' do
    visit edit_profile_path
    expect(page).not_to have_text('review committee')
    create(:event, state: 'open', blind_review: true)
    visit edit_profile_path
    expect(page).to have_text('hidden from the review committee')
  end

  scenario 'A user updates their event email preference' do
    teammate = create(:teammate, role: 'organizer', user: user, state: :accepted)
    visit(event_path(teammate.event))
    visit(notifications_profile_path)
    choose(Teammate::NOTIFICATION_PREFERENCE_LABELS['mentions'])
    click_button 'Save'
    click_link 'Dashboard'
    click_link 'Team'
    expect(page).to have_content(Teammate::NOTIFICATION_PREFERENCE_LABELS['mentions'])
  end
end
