require 'rails_helper'

feature 'EventTeammate Invitations' do
  let(:user) { create(:user) }
  let(:invitation) { create(:event_teammate_invitation, role: 'organizer') }
  let(:event) { create(:event) }

  before { login_as(user) }

  context "User has received a event_teammate invitation" do
    it "can accept the invitation" do
      visit accept_event_teammate_invitation_path(invitation.slug, invitation.token)
      expect(page).to have_text('You successfully accepted the invitation')
    end

    context "User receives incorrect or missing link in event_teammate invitation email" do
      it "shows a custom 404 error" do
        visit accept_event_teammate_invitation_path(invitation.slug, invitation.token + 'bananas')
        expect(page).to have_text('Oh My. A 404 error. Your confirmation invite link is missing or wrong.')
        expect(page).to have_text('Events')
      end
    end
  end
end
