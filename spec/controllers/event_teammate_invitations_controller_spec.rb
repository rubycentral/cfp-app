require 'rails_helper'

describe EventTeammateInvitationsController, type: :controller do
  let(:invitation) { create(:event_teammate_invitation, role: 'organizer') }

  describe "GET 'accept'" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "creates a new event_teammate for current user" do
      expect {
        get :accept, slug: invitation.slug, token: invitation.token
      }.to change { invitation.event.event_teammates.count }.by(1)
      expect(user).to be_organizer_for_event(invitation.event)
    end
  end

  describe "GET 'refuse'" do
    it "redirects to root url" do
      get 'refuse', slug: invitation.slug, token: invitation.token
      expect(response).to redirect_to(root_url)
    end

    it "sets invitation state to refused" do
      get 'refuse', slug: invitation.slug, token: invitation.token
      expect(invitation.reload.state).to eq(Invitable::State::REFUSED)
    end
  end

end
