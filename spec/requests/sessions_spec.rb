require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let!(:user) { create(:user) } # factory password is '12345678', confirmed via after(:create)

  describe 'GET /users/sign_in (legacy alias)' do
    it 'renders the sign in form' do
      get new_user_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('user_email')
    end
  end

  describe 'POST /session' do
    it 'signs in with valid credentials and sets the session cookie' do
      post session_path, params: {user: {email: user.email, password: '12345678'}}

      expect(user.sessions.count).to eq(1)
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Signed in successfully.')
      expect(cookies[:session_id]).to be_present
    end

    it 'normalizes the email' do
      post session_path, params: {user: {email: "  #{user.email.upcase}  ", password: '12345678'}}

      expect(user.sessions.count).to eq(1)
    end

    it 'rejects invalid credentials' do
      post session_path, params: {user: {email: user.email, password: 'wrongpass'}}

      expect(user.sessions.count).to eq(0)
      expect(response).to redirect_to(new_session_path)
      expect(flash[:danger]).to eq('Invalid Email or password.')
    end

    it 'rejects malformed params without raising' do
      post session_path, params: {}

      expect(response).to redirect_to(new_session_path)
      expect(flash[:danger]).to eq('Invalid Email or password.')
    end

    it 'rejects unconfirmed users' do
      unconfirmed = build(:user, email: 'unconfirmed@factory.com')
      unconfirmed.save!

      post session_path, params: {user: {email: 'unconfirmed@factory.com', password: '12345678'}}

      expect(unconfirmed.sessions.count).to eq(0)
      expect(flash[:danger]).to eq('You have to confirm your email address before continuing.')
    end
  end

  describe 'DELETE /users/sign_out (legacy alias)' do
    it 'terminates the session' do
      post session_path, params: {user: {email: user.email, password: '12345678'}}
      delete destroy_user_session_path

      expect(user.sessions.count).to eq(0)
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Signed out successfully.')
    end

    it 'is a no-op when not signed in' do
      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
    end
  end
end
