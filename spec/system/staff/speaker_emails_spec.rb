require 'rails_helper'

feature "Speaker Emails" do
  let(:event) { create(:event, name: "My Event") }
  let(:admin_user) { create(:user, admin: true) }
  let!(:admin_teammate) { create(:teammate,
                                   event: event,
                                   user: admin_user,
                                   role: "organizer"
                                  )
  }

  let(:organizer_user) { create(:user) }
  let!(:event_staff_teammate) { create(:teammate,
                                       event: event,
                                       user: organizer_user,
                                       role: "organizer")
  }

  let(:reviewer_user) { create(:user) }
  let!(:reviewer_teammate) { create(:teammate,
                                      event: event,
                                      user: reviewer_user,
                                      role: "reviewer")
  }

  let(:program_team_user) { create(:user) }
  let!(:program_team_teammate) { create(:teammate,
                                      event: event,
                                      user: program_team_user,
                                      role: "program team")
  }

  context "An admin organizer" do
    before { login_as(admin_user) }

    it "can edit speaker emails", js: true do
      visit event_staff_speaker_email_notifications_path(event)

      within first('.template-section') do
        find_button("Edit").click
        fill_in "event[accept]", with: "Yay! You've been accepted to speak!"
        find_button("Save").click
      end

      within first('.contents'), js: true do
        expect(page).to have_content "Yay! You've been accepted to speak!"
      end
    end
  end

  context "An organizer" do
    before { login_as(organizer_user) }

    it "can edit speaker emails", js: true do
      visit event_staff_speaker_email_notifications_path(event)
      within first('.template-section') do
        find_button("Edit").click
        fill_in "event[accept]", with: "Yay! You've been accepted to speak!"
        find_button("Save").click
      end

      within first('.contents'), js: true do
        expect(page).to have_content "Yay! You've been accepted to speak!"
      end
    end
  end

  context "A reviewer" do
    before { login_as(reviewer_user) }

    it "cannot edit speaker emails", js: true do
      visit event_staff_speaker_email_notifications_path(event)

      expect(page).to_not have_button "Save"
    end
  end

  context "A program_team" do
    before { login_as(program_team_user) }

    it "cannot edit speaker emails", js: true do
      visit event_staff_speaker_email_notifications_path(event)

      expect(page).to_not have_button "Save"
    end
  end
end
