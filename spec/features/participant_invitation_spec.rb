require 'rails_helper'

feature 'Participant Invitations' do
  let(:user) { create(:person) }
  let(:invitation) { create(:participant_invitation, role: 'organizer') }
  let(:event) { create(:event) }

  before { login_user(user) }

  context "User has received a participant invitation" do
    it "can accept the invitation" do
      visit accept_participant_invitation_path(invitation.slug, invitation.token)
      expect(page).to have_text('You successfully accepted the invitation')
      expect(page).to have_text('Organize')
    end

    context "User receives incorrect or missing link in participant invitation email" do
      it "shows a custom 404 error" do
        visit accept_participant_invitation_path(invitation.slug, invitation.token + 'bananas')
        expect(page).to have_text('Oh My. A 404 error. Your confirmation invite link is missing or wrong.')
        expect(page).to have_text('Events')
      end
    end
  end
end