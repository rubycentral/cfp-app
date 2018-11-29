require 'rails_helper'

describe TeammatesController, type: :controller do
  let(:invitation) { create(:teammate, :has_been_invited) }

  describe "GET 'accept'" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "creates an accepted teammate for current user" do
      expect(invitation.state).to eq(Teammate::PENDING)
      get :accept, params: {token: invitation.token}
      expect(user).to be_reviewer_for_event(invitation.event)
      invitation.reload
      expect(invitation.state).to eq(Teammate::ACCEPTED)
    end
  end

  describe "GET 'decline'" do
    it "redirects to root url" do
      get :decline, params: {token: invitation.token}
      expect(response).to redirect_to(root_url)
    end

    it "sets invitation state to declined" do
      get :decline, params: {token: invitation.token}
      expect(invitation.reload.state).to eq(Teammate::DECLINED)
    end
  end

end
