require 'rails_helper'

feature "Staff Organizers can manage event_teammates" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { login_as(organizer) }

  context "adding a new event_teammate" do
    it "invites a new teammate", js: true do
      visit event_staff_team_index_path(event)

      click_link 'Invite new event teammate'
      fill_in 'Email', with: 'harrypotter@hogwarts.edu'
      select('reviewer', from: 'Role')
      click_button 'Invite'

      expect(page).to have_text('harrypotter@hogwarts.edu')
      expect(page).to have_text('pending')
    end
  end
end
