require 'spec_helper'

feature 'Participant Invitations' do
  let(:user) { create(:person) }
  let(:invitation) { create(:participant_invitation, role: 'organizer') }

  before { login_user(user) }

  context "User has received a participant invitation" do
    it "can accept the invitation" do
      visit accept_participant_invitation_path(invitation.slug, invitation.token)
      expect(page).to have_text('You successfully accepted the invitation')
      expect(page).to have_text('Organize')
    end
  end

end
