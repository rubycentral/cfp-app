require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  let!(:user) { create(:user) } # factory password is '12345678', confirmed via after(:create)

  describe 'PATCH /passwords/:token (reset)' do
    it 'destroys all of the user sessions on a successful reset' do
      user.sessions.create!

      expect(user.sessions.count).to eq(1)

      patch password_path(user.password_reset_token), params: {
        user: {password: 'newpassword123', password_confirmation: 'newpassword123'}
      }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:notice]).to eq('Password has been reset.')
      expect(user.sessions.count).to eq(0)
    end

    it 'does not destroy sessions when the password confirmation mismatches' do
      user.sessions.create!
      token = user.password_reset_token

      patch password_path(token), params: {
        user: {password: 'newpassword123', password_confirmation: 'doesnotmatch'}
      }

      expect(response).to redirect_to(edit_password_path(token))
      expect(user.sessions.count).to eq(1)
    end

    it 'does not destroy sessions when the token is invalid or expired' do
      user.sessions.create!

      patch password_path('bogus-invalid-token'), params: {
        user: {password: 'newpassword123', password_confirmation: 'newpassword123'}
      }

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to eq('Password reset link is invalid or has expired.')
      expect(user.sessions.count).to eq(1)
    end
  end

  describe 'PATCH /profile (signed-in password change)' do
    it 'destroys the other sessions but keeps the current one when changing password' do
      current_session = user.sessions.create!
      other_session = user.sessions.create!

      cookies[:session_id] = signed_session_cookie(current_session)

      patch profile_path, params: {
        user: {password: 'newpassword123', password_confirmation: 'newpassword123'}
      }

      expect(response).to redirect_to(root_url)
      expect(user.sessions.reload).to contain_exactly(current_session)
      expect(Session.exists?(other_session.id)).to be false
    end

    it 'keeps all sessions intact when updating the profile without a password' do
      current_session = user.sessions.create!
      other_session = user.sessions.create!

      cookies[:session_id] = signed_session_cookie(current_session)

      patch profile_path, params: {user: {name: 'A New Name'}}

      expect(user.sessions.reload).to contain_exactly(current_session, other_session)
    end
  end
end
