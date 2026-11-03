require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'GET /users/sign_up (legacy alias)' do
    it 'renders the sign up form' do
      get new_registration_path

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
      proposal = create(:proposal_with_track)
      invitation = create(:invitation, proposal: proposal, email: 'invited@person.com')

      # Drive the real flow: visiting the invitation-accept URL while signed
      # out sets session[:pending_invite_email] (via InvitationsController's
      # set_session_invite before_action) before bouncing to sign-in.
      get accept_invitation_path(invitation.slug)
      expect(response).to redirect_to(new_session_url)

      invited = params.deep_merge(user: {email: 'invited@person.com'})

      expect {
        expect { post registration_path, params: invited }
          .not_to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)
      }.to change(User, :count).by(1)

      user = User.find_by(email: 'invited@person.com')
      expect(user.confirmed?).to be true
      expect(user.sessions.count).to eq(1)
      expect(flash[:notice]).to eq('Welcome! You have signed up successfully.')
    end

    it 'does not auto-confirm from a client-supplied pending_invite_email without a matching session' do
      spoofed = params.deep_merge(user: {email: 'x@y.z', pending_invite_email: 'x@y.z'})

      post registration_path, params: spoofed

      user = User.find_by(email: 'x@y.z')
      expect(user).to be_present
      expect(user.confirmed?).to be false
      expect(user.sessions.count).to eq(0)
    end

    it 're-renders on validation failure' do
      post registration_path, params: {user: {email: 'bad', password: 'x', password_confirmation: 'y'}}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.find_by(email: 'bad')).to be_nil
    end

    it 'consumes the pending-invite session keys after a successful confirmed signup' do
      proposal = create(:proposal_with_track)
      invitation = create(:invitation, proposal: proposal, email: 'invited@person.com')

      get accept_invitation_path(invitation.slug)
      expect(response).to redirect_to(new_session_url)

      invited = params.deep_merge(user: {email: 'invited@person.com'})
      post registration_path, params: invited

      user = User.find_by(email: 'invited@person.com')
      expect(user.confirmed?).to be true
      user.destroy

      # A second registration in the same session, with the SAME email as
      # the (now-stale) pending invite, must NOT auto-confirm: the invite
      # session keys should have been consumed by the first signup.
      expect { post registration_path, params: invited }
        .to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)

      second_user = User.find_by(email: 'invited@person.com')
      expect(second_user.confirmed?).to be false
      expect(second_user.sessions.count).to eq(0)
    end
  end
end
