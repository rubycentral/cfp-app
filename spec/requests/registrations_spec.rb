require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'GET /users/sign_up (legacy alias)' do
    it 'renders the sign up form' do
      get new_user_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('user_email').and include('user_password_confirmation')
    end
  end

  describe 'POST /registration' do
    let(:params) { {user: {email: 'new@person.com', password: 'secret99', password_confirmation: 'secret99'}} }

    it 'creates an unconfirmed user, sends confirmation instructions, does not sign in' do
      expect { post registration_path, params: params }
        .to change(User, :count).by(1)
        .and have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)

      user = User.find_by(email: 'new@person.com')
      expect(user.confirmed?).to be false
      expect(user.sessions.count).to eq(0)
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.')
    end

    it 'auto-confirms and signs in an invited user whose email matches, without a confirmation email' do
      invited = params.deep_merge(user: {email: 'invited@person.com', pending_invite_email: 'invited@person.com'})

      expect {
        expect { post registration_path, params: invited }
          .not_to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)
      }.to change(User, :count).by(1)

      user = User.find_by(email: 'invited@person.com')
      expect(user.confirmed?).to be true
      expect(user.sessions.count).to eq(1)
      expect(flash[:notice]).to eq('Welcome! You have signed up successfully.')
    end

    it 're-renders on validation failure' do
      post registration_path, params: {user: {email: 'bad', password: 'x', password_confirmation: 'y'}}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.find_by(email: 'bad')).to be_nil
    end
  end
end
