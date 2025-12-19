require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :controller do
  before do
    Rails.application.reload_routes_unless_loaded
  end

  describe '#twitter' do
    let(:twitter_auth_hash) { OmniAuth.config.mock_auth[:twitter] }
    let(:github_auth_hash) { OmniAuth.config.mock_auth[:github] }
    let(:user) { build(:user) }
    let(:invitation) { build(:invitation, slug: "abc123", email: 'foo@example.com') }
    let(:other_invitation) { build(:invitation, slug: "def456", email: 'foo@example.com') }

    before :each do
      session[:invitation_slug] = invitation.slug
      request.env['omniauth.auth'] = twitter_auth_hash
      request.env['devise.mapping'] = Devise.mappings[:user]
      allow(controller).to receive(:current_user).and_return(User.last)
    end

    it "allows twitter login" do
      get :twitter
      expect(response).to redirect_to(edit_profile_url)
    end
  end

  describe "GET #new" do
    let(:github_auth_hash) { OmniAuth.config.mock_auth[:github] }

    before :each do
      request.env['omniauth.auth'] = github_auth_hash
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it "redirects a user if they are currently logged in" do
      organizer = create(:organizer)
      sign_in(organizer)
      get :github

      expect(response).to redirect_to(events_url)
      expect(controller.current_user).to eq(organizer)
    end
  end
end
