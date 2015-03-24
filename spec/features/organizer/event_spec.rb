require 'rails_helper'

feature "Event Dashboard" do
  let(:event) { create(:event, name: "My Event") }
  let(:admin_user) { create(:person, admin: true) }
  let!(:admin_participant) { create(:participant,
                                   event: event,
                                   person: admin_user,
                                   role: 'organizer'
                                  )
  }

  let(:organizer_user) { create(:person) }
  let!(:organizer_participant) { create(:participant,
                                       event: event,
                                       person: organizer_user,
                                       role: 'organizer')
  }

  let(:reviewer_user) { create(:person) }
  let!(:reviewer_participant) { create(:participant,
                                      event: event,
                                      person: reviewer_user,
                                      role: 'reviewer')
  }

  context "An admin" do
    before { login_user(admin_user) }

    it "can create a new event" do
      visit new_admin_event_path
      fill_in "Name", with: "My Other Event"
      fill_in "Contact email", with: "me@example.com"
      fill_in "Start date", with: DateTime.now + 10.days
      fill_in "End date", with: DateTime.now + 15.days
      click_button 'Save'
      admin_user.reload
      expect(admin_user.organizer_events.last.name).to eql("My Other Event")
    end

    it "can edit an event" do
      visit edit_organizer_event_path(event)
      fill_in "Name", with: "My Finest Event Evar For Realz"
      click_button 'Save'
      expect(page).to have_text("My Finest Event Evar For Realz")
    end

    it "can delete events" do
      visit edit_organizer_event_path(event)
      click_link 'Delete Event'
      expect(page).not_to have_text("My Event")
    end
  end

  context "As an organizer" do
    before { login_user(organizer_user) }

    it "cannot create new events" do
      visit new_admin_event_path
      expect(page).to have_text("You must be signed in as an administrator")
    end

    it "can edit events" do
      visit edit_organizer_event_path(event)
      fill_in "Name", with: "Blef"
      click_button 'Save'
      expect(page).to have_text("Blef")
    end

    it "cannot delete events" do
      visit organizer_event_path(event)
      expect(page).not_to have_link('Delete Event')
    end

    it "can promote a person" do
      person = create(:person)
      visit organizer_event_path(event)
      click_link 'Add/Invite New Participant'

      form = find('#new_participant')
      form.fill_in :email, with: person.email
      form.select 'organizer', from: 'Role'
      form.click_button('Save')

      expect(person).to be_organizer_for_event(event)
    end

    it "can promote a participant" do
      visit organizer_event_path(event)

      form = find('tr', text: reviewer_user.email).find('form')
      form.select 'organizer', from: 'Role'
      form.click_button('Save')

      expect(reviewer_user).to be_organizer_for_event(event)
    end

    it "can remove a participant" do
      visit organizer_event_path(event)

      row = find('tr', text: reviewer_user.email)
      row.click_link 'Remove'

      expect(reviewer_user).to_not be_reviewer_for_event(event)
    end

    it "can invite a new participant" do
      visit organizer_event_participant_invitations_path(event)

      fill_in 'Email', with: 'harrypotter@hogwarts.edu'
      select 'organizer', from: 'Role'
      click_button('Invite')

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq([ 'harrypotter@hogwarts.edu' ])
      expect(page).to have_text('Participant invitation successfully sent')
    end
  end
end
