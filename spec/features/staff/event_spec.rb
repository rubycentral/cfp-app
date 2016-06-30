require 'rails_helper'

feature "Event Dashboard" do
  let(:event) { create(:event, name: "My Event") }
  let(:admin_user) { create(:user, admin: true) }
  let!(:admin_event_teammate) { create(:event_teammate,
                                   event: event,
                                   user: admin_user,
                                   role: 'organizer'
                                  )
  }

  let(:organizer_user) { create(:user) }
  let!(:event_staff_teammate) { create(:event_teammate,
                                       event: event,
                                       user: organizer_user,
                                       role: 'organizer')
  }

  let(:reviewer_user) { create(:user) }
  let!(:reviewer_event_teammate) { create(:event_teammate,
                                      event: event,
                                      user: reviewer_user,
                                      role: 'reviewer')
  }

  context "An admin" do
    before { login_as(admin_user) }

    it "can create a new event" do
      visit new_admin_event_path
      fill_in "Name", with: "My Other Event"
      fill_in "Contact email", with: "me@example.com"
      fill_in "Start date", with: DateTime.now + 10.days
      fill_in "End date", with: DateTime.now + 15.days
      fill_in "Closes at", with: DateTime.now + 15.days
      click_button 'Save'
      admin_user.reload
      expect(admin_user.organizer_events.last.name).to eql("My Other Event")
    end

    it "can edit an event" do
      visit event_staff_edit_path(event)
      fill_in "Name", with: "My Finest Event Evar For Realz"
      click_button 'Save'
      expect(page).to have_text("My Finest Event Evar For Realz")
    end

    it "can delete events" do
      visit event_staff_edit_path(event)
      click_link 'Delete Event'
      expect(page).not_to have_text("My Event")
    end
  end

  context "As an organizer" do
    before :each do
      logout
      login_as(organizer_user)
    end

    it "cannot create new events" do
      pending "This fails because it sends them to login and then Devise sends to events path and changes flash"
      visit new_admin_event_path
      expect(page.current_path).to eq(events_path)
      #Losing the flash on redirect here.
      expect(page).to have_text("You must be signed in as an administrator")
    end

    it "can edit events" do
      visit event_staff_edit_path(event)
      fill_in "Name", with: "Blef"
      click_button 'Save'
      expect(page).to have_text("Blef")
    end

    it "cannot delete events" do
      visit event_staff_url(event)
      expect(page).not_to have_link('Delete Event')
    end

    it "can promote a user" do
      user = create(:user)
      visit event_staff_path(event)
      click_link 'Add/Invite Staff'

      form = find('#new_event_teammate')
      form.fill_in :email, with: user.email
      form.select 'organizer', from: 'Role'
      form.click_button('Save')

      expect(user).to be_organizer_for_event(event)
    end

    it "can promote an event teammate" do
      visit event_staff_path(event)

      form = find('tr', text: reviewer_user.email).find('form')
      form.select 'organizer', from: 'Role'
      form.click_button('Save')

      expect(reviewer_user).to be_organizer_for_event(event)
    end

    it "can remove a event teammate" do
      visit event_staff_path(event)

      row = find('tr', text: reviewer_user.email)
      row.click_link 'Remove'

      expect(reviewer_user).to_not be_reviewer_for_event(event)
    end

    it "can invite a new event teammate" do
      visit event_staff_event_teammate_invitations_path(event)

      fill_in 'Email', with: 'harrypotter@hogwarts.edu'
      select 'program team', from: 'Role'
      click_button('Invite')

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq([ 'harrypotter@hogwarts.edu' ])
      expect(page).to have_text('Event teammate invitation successfully sent')
    end
  end
end
