require 'rails_helper'

feature "Organizers can manage participants" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { login_user(organizer) }

  context "adding a new participant" do
    it "autocompletes email addresses", js: true do
      create(:person, email: 'harrypotter@hogwarts.edu')
      create(:person, email: 'hermionegranger@hogwarts.edu')
      create(:person, email: 'viktorkrum@durmstrang.edu')
      visit organizer_event_path(event)

      click_link 'Add/Invite New Participant'
      fill_in 'email', with: 'h'

      expect(page).to have_text('harrypotter@hogwarts.edu')
      expect(page).to have_text('hermionegranger@hogwarts.edu')
      expect(page).to_not have_text('viktorkrum@durmstrang.edu')
    end
  end
end
