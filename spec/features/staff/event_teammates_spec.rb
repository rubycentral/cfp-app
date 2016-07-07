require 'rails_helper'

feature "Staff Organizers can manage event_teammates" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { login_as(organizer) }

  context "adding a new event_teammate" do
    it "autocompletes email addresses", js: true do
      skip "Did this ever work?!"
      create(:user, email: 'harrypotter@hogwarts.edu')
      create(:user, email: 'hermionegranger@hogwarts.edu')
      create(:user, email: 'viktorkrum@durmstrang.edu')
      visit event_staff_event_teammate_invitations_path(event)

      click_link 'Invite new event teammate'
      fill_in 'event_teammate_invitation_email', with: 'harrypotter@hogwarts.edu'
      select('reviewer', from: 'Role')
      click_button 'Invite'

      expect(page).to have_text('harrypotter@hogwarts.edu')
      expect(page).to have_text('hermionegranger@hogwarts.edu')
      expect(page).to_not have_text('viktorkrum@durmstrang.edu')
    end

    it "invites a teammate by email addresses", js: true do
      visit event_staff_event_teammate_invitations_path(event)

      click_link 'Invite new event teammate'
      fill_in 'event_teammate_invitation_email', with: 'harrypotter@hogwarts.edu'
      select('reviewer', from: 'Role')
      click_button 'Invite'

      expect(page).to have_text('harrypotter@hogwarts.edu')
      expect(page).to have_text('pending')
    end
  end
end
