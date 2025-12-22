require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :controller do
  before do
    Rails.application.reload_routes_unless_loaded
  end

  let(:twitter_auth_hash) { OmniAuth.config.mock_auth[:twitter] }
  let(:github_auth_hash) { OmniAuth.config.mock_auth[:github] }

  describe '#twitter' do
    let(:user) { build(:user) }
    let(:invitation) { build(:invitation, slug: 'abc123', email: 'foo@example.com') }

    before :each do
      session[:invitation_slug] = invitation.slug
      request.env['omniauth.auth'] = twitter_auth_hash
      request.env['devise.mapping'] = Devise.mappings[:user]
      allow(controller).to receive(:current_user).and_return(User.last)
    end

    it 'allows twitter login for new user' do
      get :twitter
      expect(response).to redirect_to(edit_profile_url)
      expect(User.last.identities.find_by(provider: 'twitter')).to be_present
    end
  end

  describe 'signing in' do
    before :each do
      request.env['omniauth.auth'] = github_auth_hash
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'when user exists with identity' do
      let!(:user) { create(:user) }
      let!(:identity) { user.identities.create!(provider: 'github', uid: github_auth_hash.uid) }

      it 'finds user via identity and signs in' do
        expect { get :github }.not_to change { User.count }
        expect(controller.current_user).to eq(user)
      end
    end

    context 'when user exists with legacy provider/uid on User' do
      let!(:user) { create(:user, provider: 'github', uid: github_auth_hash.uid) }

      it 'finds user via legacy lookup and signs in' do
        expect { get :github }.not_to change { User.count }
        expect(controller.current_user).to eq(user)
      end
    end
  end

  describe 'linking identity to logged-in user' do
    before :each do
      request.env['omniauth.auth'] = github_auth_hash
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'when connecting a new provider' do
      it 'creates identity and redirects to profile' do
        user = create(:user)
        sign_in(user)

        expect { get :github }.to change { user.identities.count }.by(1)
        expect(response).to redirect_to(edit_profile_path)
        expect(flash[:info]).to eq('Successfully connected GitHub to your account.')
      end
    end

    context 'when provider is already connected to current user' do
      it 'shows already connected message' do
        user = create(:user)
        user.identities.create!(provider: 'github', uid: github_auth_hash.uid)
        sign_in(user)

        expect { get :github }.not_to change { Identity.count }
        expect(response).to redirect_to(edit_profile_path)
        expect(flash[:info]).to eq('GitHub is already connected to your account.')
      end
    end

    context 'when provider is already connected to another user' do
      it 'shows error message' do
        other_user = create(:user)
        other_user.identities.create!(provider: 'github', uid: github_auth_hash.uid)

        user = create(:user)
        sign_in(user)

        expect { get :github }.not_to change { Identity.count }
        expect(response).to redirect_to(edit_profile_path)
        expect(flash[:danger]).to eq('This GitHub account is already connected to another user.')
      end
    end

    context 'when legacy user exists with same provider/uid' do
      it 'redirects to merge page' do
        legacy_user = create(:user, provider: 'github', uid: github_auth_hash.uid)
        user = create(:user)
        sign_in(user)

        get :github

        expect(response).to redirect_to(merge_profile_path)
        expect(session[:pending_merge_user_id]).to eq(legacy_user.id)
        expect(session[:pending_merge_provider]).to eq('github')
        expect(session[:pending_merge_uid]).to eq(github_auth_hash.uid)
      end
    end
  end
end
