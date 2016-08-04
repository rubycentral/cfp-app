require 'rails_helper'

feature "Teammate Invitations" do
  let(:event) { create(:event, name: "My Event") }
  let!(:organizer_user) { create(:user) }
  let!(:organizer_teammate) { create(:teammate, :organizer, user: organizer_user, event: invitation.event, state: Teammate::ACCEPTED) }

  let(:invitation) { create(:teammate, :has_been_invited, event: event) }

  let!(:regular_user_1) { create(:user) }
  let!(:regular_user_2) { create(:user) }

  context "User has received a teammate invitation" do
    it "can accept the invitation" do
      visit accept_teammate_path(invitation.token)

      expect(page).to have_content("Team invite to #{invitation.event.name} accepted!")
      expect(page).to have_content("Thanks for joining our team.")
      expect(page).to have_link("Log in")
      expect(page).to have_button("Create your Account")
    end

    it "a logged in user can accept an invitation" do
      login_as(regular_user_1)

      visit accept_teammate_path(invitation.token)

      expect(page).to have_content("Congrats! You are now an official team member of #{invitation.event.name}!")
    end

    it "can decline the invitation" do
      visit decline_teammate_path(invitation.token)

      expect(page).to have_content("You declined the invitation to #{invitation.event.name}.")
    end

    it "a logged in user can decline an invitation to be a teammate" do
      login_as(regular_user_2)

      visit decline_teammate_path(invitation.token)

      expect(page).to have_content("You declined the invitation to #{invitation.event.name}.")
    end

    context "User receives incorrect or missing link in teammate invitation email" do
      it "shows a custom 404 error" do
        visit accept_teammate_path(invitation.token + "bananas")
        expect(page).to have_text("Oh My. A 404 error. Your confirmation invite link is missing or wrong.")
        expect(page).to have_text("Events")
      end
    end
  end
end
