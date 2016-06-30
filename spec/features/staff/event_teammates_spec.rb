require 'rails_helper'

feature "Staff Organizers can manage event_teammates" do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { login_as(organizer) }

  context "adding a new event_teammate" do
    pending "This fails because add/invite new teammate is no longer on this page. Change path once new card is complete"
    it "autocompletes email addresses", js: true do
      create(:user, email: 'harrypotter@hogwarts.edu')
      create(:user, email: 'hermionegranger@hogwarts.edu')
      create(:user, email: 'viktorkrum@durmstrang.edu')
      visit event_staff_path(event)

      click_link 'Add/Invite Staff'
      fill_in 'email', with: 'h'

      expect(page).to have_text('harrypotter@hogwarts.edu')
      expect(page).to have_text('hermionegranger@hogwarts.edu')
      expect(page).to_not have_text('viktorkrum@durmstrang.edu')
    end
  end
end
