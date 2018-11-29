require 'rails_helper'

feature "Organizers can manage speakers for Program Sessions" do

  let(:event) { create(:event) }

  let(:proposal_1) { create(:proposal, event: event) }
  let(:proposal_2) { create(:proposal, event: event) }

  let(:program_session_1) { create(:program_session_with_proposal, event: event) }
  let(:program_session_2) { create(:program_session_with_proposal, event: event) }

  let(:organizer_user) { create(:user) }
  let!(:event_staff_teammate) { create(:teammate, :organizer, user: organizer_user, event: event) }

  let(:speaker_user_1) { create(:user) }
  let!(:speaker_1) { create(:speaker, proposal: proposal_1,
                                      user: speaker_user_1) }

  let(:speaker_user_2) { create(:user) }
  let!(:speaker_2) { create(:speaker, proposal: proposal_2,
                                      user: speaker_user_2) }

  let(:speaker_user_3) { create(:user) }
  let!(:speaker_3) { create(:speaker, program_session: program_session_1,
                                      user: speaker_user_3) }

  let(:speaker_user_4) { create(:user) }
  let!(:speaker_4) { create(:speaker, program_session: program_session_1,
                                      user: speaker_user_4) }

  let(:speaker_user_5) { create(:user) }
  let!(:speaker_5) { create(:speaker, program_session: program_session_2,
                                      user: speaker_user_5) }

  before :each do
    logout
    login_as(organizer_user)
    visit event_staff_program_speakers_path(event)
  end

  context "An organizer" do
    it "Only sees speakers of program sessions" do
      expect(page).to have_content(speaker_3.name)
      expect(page).to have_content(speaker_3.email)
      # check for program session title linking to ?program session show page?

      expect(page).to have_content(speaker_4.name)
      expect(page).to have_content(speaker_4.email)

      expect(page).to have_content(speaker_5.name)
      expect(page).to have_content(speaker_5.email)

      expect(page).to_not have_content(speaker_1.name)
      expect(page).to_not have_content(speaker_1.email)

      expect(page).to_not have_content(speaker_2.name)
      expect(page).to_not have_content(speaker_2.email)
    end

    it "Can edit a program sessions speaker" do
      row = find("tr#speaker-#{speaker_3.id}")
      old_name = speaker_3.name
      old_email = speaker_3.email
      old_bio = speaker_3.bio

      within row do
        expect(page).to have_content(old_name)
        expect(page).to have_content(old_email)
        click_on "Edit"
      end

      expect(current_path).to eq(edit_event_staff_program_speaker_path(event, speaker_3))

      fill_in "speaker[speaker_name]", with: "New Name"
      fill_in "speaker[speaker_email]", with: "new@email.com"
      fill_in "speaker[bio]", with: "New bio!"

      click_on "Save"

      expect(current_path).to eq(event_staff_program_speakers_path(event))

      expect(page).to_not have_content(old_name)
      expect(page).to_not have_content(old_email)

      expect(page).to have_content "New Name"
      expect(page).to have_content "new@email.com"

      # User name and email remain the same
      expect(speaker_3.name).to eq old_name
      expect(speaker_3.email).to eq old_email
      expect(speaker_3.bio).to eq old_bio

      # Speaker record is updated separately
      speaker_profile = Speaker.find_by(id: speaker_3.id)
      expect(speaker_profile.name).to eq "New Name"
      expect(speaker_profile.email).to eq "new@email.com"
      expect(speaker_profile.bio).to eq "New bio!"
    end

    it "Can't update a speaker with a bad email" do
      row = find("tr#speaker-#{speaker_3.id}")
      within row do
        click_on "Edit"
      end

      fill_in "speaker[speaker_name]", with: "Penny"
      fill_in "speaker[speaker_email]", with: "gobbiltygook"
      click_on "Save"

      expect(page).to have_content "There was a problem updating this speaker."
    end

    it "Can't update a speaker to have no email" do
      pending "Currently you *can* update a speaker associated with a user to have no email - investigating"
      row = find("tr#speaker-#{speaker_3.id}")
      within row do
        click_on "Edit"
      end

      fill_in "speaker[speaker_name]", with: "Penny"
      fill_in "speaker[speaker_email]", with: ""
      click_on "Save"

      expect(page).to have_content "There was a problem updating this speaker."
    end

    it "Can't update a speaker to have no name" do
      pending "Currently you *can* update a speaker associated with a user to have no name - investigating"
      row = find("tr#speaker-#{speaker_3.id}")
      within row do
        click_on "Edit"
      end

      fill_in "speaker[speaker_name]", with: ""
      fill_in "speaker[speaker_email]", with: "goodemail@example.com"
      click_on "Save"

      expect(page).to have_content "There was a problem updating this speaker."
    end
  end
end
