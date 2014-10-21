require 'rails_helper'

describe SessionsController, type: :controller do
  describe '#create' do
    let(:auth_hash) { double("OmniAuth::AuthHash") }
    let(:user) { build_stubbed(:person) }
    let(:service) { build_stubbed(:service, person: user) }
    let(:invitation) { build_stubbed(:invitation, slug: "abc123", email: 'foo@example.com') }
    let(:other_invitation) { build_stubbed(:invitation, slug: "def456", email: 'foo@example.com') }

    before :each do
      session[:invitation_slug] = invitation.slug
      request.env['omniauth.auth'] = auth_hash
      allow(controller).to receive(:current_user).and_return(user)
    end

    it "adds any pending invitations to the new person record" do
      allow(Person).to receive(:authenticate).with(auth_hash, user).and_return([service, user])
      allow(Invitation).to receive(:find_by).and_return(invitation)
      allow(Invitation).to receive(:where).and_return([other_invitation])

      expect(other_invitation).to receive(:update_column).and_return(true)
      post :create, name: 'foo', email: 'foo@example.com', provider: 'developer'
    end

  end

  describe "GET #new" do
    it "redirects a user if they are currently logged in" do
      organizer = create(:organizer)
      login(organizer)
      get :new

      expect(response).to redirect_to(root_url)
    end
  end
end
