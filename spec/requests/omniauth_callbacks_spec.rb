require 'rails_helper'

# OmniAuth runs in test mode (spec/support/omniauth.rb), so hitting a provider's
# callback path directly hands the controller that provider's mock auth hash.
RSpec.describe 'OmniAuth callbacks', type: :request do
  let(:github_auth_hash) { OmniAuth.config.mock_auth[:github] }

  def github_callback
    get omniauth_callback_path(provider: 'github')
  end

  describe 'signing in' do
    it 'creates an account and its identity for a first-time Twitter user' do
      expect { get omniauth_callback_path(provider: 'twitter') }.to change(User, :count).by(1)
      expect(User.last.identities.find_by(provider: 'twitter')).to be_present
      # Twitter hands over no email, so the profile needs completing
      expect(response).to redirect_to(edit_profile_url)
    end

    it 'finds an existing user through their identity' do
      user = create(:user)
      user.identities.create!(provider: 'github', uid: github_auth_hash.uid)

      expect { github_callback }.not_to change(User, :count)
      expect(user.sessions.count).to eq(1)
    end

    it 'finds an existing user through the legacy provider and uid columns' do
      user = create(:user, provider: 'github', uid: github_auth_hash.uid)

      expect { github_callback }.not_to change(User, :count)
      expect(user.sessions.count).to eq(1)
    end
  end

  describe 'connecting a provider while signed in' do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it 'links a new provider to the current account' do
      expect { github_callback }.to change { user.identities.count }.by(1)
      expect(response).to redirect_to(edit_profile_path)
      expect(flash[:info]).to eq('Successfully connected GitHub to your account.')
    end

    it 'says so when the provider is already connected to this account' do
      user.identities.create!(provider: 'github', uid: github_auth_hash.uid)

      expect { github_callback }.not_to change(Identity, :count)
      expect(response).to redirect_to(edit_profile_path)
      expect(flash[:info]).to eq('GitHub is already connected to your account.')
    end

    it 'refuses a provider account that belongs to someone else' do
      create(:user).identities.create!(provider: 'github', uid: github_auth_hash.uid)

      expect { github_callback }.not_to change(Identity, :count)
      expect(response).to redirect_to(edit_profile_path)
      expect(flash[:danger]).to eq('This GitHub account is already connected to another user.')
    end

    it 'offers to merge when a legacy account used that provider' do
      legacy_user = create(:user, provider: 'github', uid: github_auth_hash.uid)

      github_callback

      expect(response).to redirect_to(merge_profile_path)
      expect(session[:pending_merge_user_id]).to eq(legacy_user.id)
      expect(session[:pending_merge_provider]).to eq('github')
      expect(session[:pending_merge_uid]).to eq(github_auth_hash.uid)
    end
  end
end
