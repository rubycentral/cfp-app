require 'rails_helper'

feature "Users Admin Dashboard" do
  let(:admin_user) { create(:user, admin: true) }
  let!(:admin_teammate) { create(:teammate, user: admin_user, role: 'organizer')}

  let(:organizer_user) { create(:user) }
  let!(:organizer_teammate) { create(:teammate, user: organizer_user, role: 'organizer')}

  let(:reviewer_user) { create(:user) }
  let!(:reviewer_teammate) { create(:teammate, user: reviewer_user, role: 'reviewer')}

  let(:speaker_user) { create(:user) }
  let!(:speaker) { create(:speaker, user: speaker_user) }

  context "An admin" do
    before { login_as(admin_user) }

    it "can see a list of all users" do
      visit admin_users_path

      within("tr#user-#{admin_user.id}") do
        expect(page).to have_content admin_user.name
        expect(page).to have_content admin_user.email
        expect(page).to have_content admin_teammate.role
      end

      within("tr#user-#{organizer_user.id}") do
        expect(page).to have_content organizer_user.name
        expect(page).to have_content organizer_user.email
        expect(page).to have_content organizer_teammate.role
      end

      within("tr#user-#{reviewer_user.id}") do
        expect(page).to have_content reviewer_user.name
        expect(page).to have_content reviewer_user.email
        expect(page).to have_content reviewer_teammate.role
      end

      within("tr#user-#{speaker_user.id}") do
        expect(page).to have_content speaker_user.name
        expect(page).to have_content speaker_user.email
      end
    end

    it "can edit a user" do
      visit admin_users_path

      old_name = reviewer_user.name
      old_email = reviewer_user.email

      within("tr#user-#{reviewer_user.id}") do
        click_on "Edit"
      end

      expect(current_path).to eq(edit_admin_user_path(reviewer_user))
      fill_in "Name", with: "Better Name"
      fill_in "Email address", with: "newemail@reviewer.com"
      click_on "Save"

      expect(current_path).to eq(admin_users_path)

      within("tr#user-#{reviewer_user.id}") do
        expect(page).to have_content "Better Name"
        expect(page).to have_content "newemail@reviewer.com"

        expect(page).to_not have_content(old_name)
        expect(page).to_not have_content(old_email)
      end
    end

    it "can delete a user", js: true do
      visit admin_users_path

      within("tr#user-#{organizer_user.id}") do
        page.accept_confirm { click_on "Delete" }
      end

      expect(page).to have_content "User account for #{organizer_user.name} was successfully deleted."
      page.reset!

      expect(page).to_not have_content organizer_teammate.name
      expect(page).to_not have_content organizer_teammate.email
    end
  end
end
