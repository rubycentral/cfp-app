require 'rails_helper'

RSpec.describe 'Confirmations', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) do
    u = build(:user, email: 'pending@person.com')
    u.save!
    u
  end

  describe 'GET /confirmations/:token' do
    it 'confirms with a valid token' do
      get confirmation_path(user.email_confirmation_token)

      expect(user.reload.confirmed?).to be true
      expect(response).to redirect_to(new_session_path)
      expect(flash[:notice]).to eq('Your email address has been successfully confirmed.')
    end

    it 'promotes a pending email change' do
      user.confirm!
      user.update_columns(unconfirmed_email: 'changed@person.com')

      get confirmation_path(user.email_confirmation_token)

      expect(user.reload.email).to eq('changed@person.com')
    end

    it 'rejects expired tokens' do
      token = user.email_confirmation_token
      travel 4.days do
        get confirmation_path(token)

        expect(user.reload.confirmed?).to be false
        expect(response).to redirect_to(new_confirmation_path)
        expect(flash[:danger]).to eq('Confirmation token is invalid or has expired.')
      end
    end

    it 'rejects tampered tokens' do
      get confirmation_path("#{user.email_confirmation_token}x")

      expect(user.reload.confirmed?).to be false
      expect(flash[:danger]).to eq('Confirmation token is invalid or has expired.')
    end

    it 'does not 500 when the pending email was taken by another user before the link was clicked' do
      user.confirm!
      user.update_columns(unconfirmed_email: 'taken@person.com')
      create(:user, email: 'taken@person.com')

      get confirmation_path(user.email_confirmation_token)

      expect(response).to redirect_to(new_confirmation_path)
      expect(flash[:danger]).to include('taken')
      expect(user.reload.email).to eq('pending@person.com')
    end
  end

  describe 'POST /confirmations (resend)' do
    it 'resends to an unconfirmed user' do
      # Force the lazy `let(:user)` to be created (and its own creation-time
      # confirmation email enqueued) before the assertion block, so only the
      # explicit resend below is being measured.
      email = user.email

      expect { post confirmations_path, params: {user: {email: email}} }
        .to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)

      expect(response).to redirect_to(new_session_path)
      expect(flash[:notice]).to eq('You will receive an email with instructions for how to confirm your email address in a few minutes.')
    end

    it 'finds users by pending email' do
      confirmed = create(:user)
      confirmed.update_columns(unconfirmed_email: 'pend2@person.com')

      expect { post confirmations_path, params: {user: {email: 'pend2@person.com'}} }
        .to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)
    end

    it 'errors for an already-confirmed user' do
      confirmed = create(:user)

      expect { post confirmations_path, params: {user: {email: confirmed.email}} }
        .not_to have_enqueued_mail

      expect(response.body).to include('was already confirmed, please try signing in')
    end

    it 'does not latch onto an oauth user with a blank email when the submitted email is blank' do
      create(:user, email: '', provider: 'twitter', uid: '99999')

      expect { post confirmations_path, params: {user: {email: ''}} }
        .not_to have_enqueued_mail

      expect(response.body).to include('not found')
    end

    it 'errors for an unknown email' do
      expect { post confirmations_path, params: {user: {email: 'nobody@nowhere.com'}} }
        .not_to have_enqueued_mail

      expect(response.body).to include('not found')
    end
  end

  describe 'POST /confirmations rate limiting' do
    # Same store-swap technique as SessionsController's rate-limit spec (see
    # spec/requests/sessions_spec.rb): the `rate_limit` before_action captures
    # a concrete cache store object at class-load time, so reassigning
    # Rails.cache afterwards has no effect. Swap the captured local directly.
    around do |example|
      rate_limit_callback = ConfirmationsController._process_action_callbacks.find { |c| c.filter.is_a?(Proc) }
      binding = rate_limit_callback.filter.binding
      original_store = binding.local_variable_get(:store)
      binding.local_variable_set(:store, ActiveSupport::Cache::MemoryStore.new)
      example.run
      binding.local_variable_set(:store, original_store)
    end

    it 'redirects with a rate limit message after 10 attempts' do
      email = user.email

      10.times do
        post confirmations_path, params: {user: {email: email}}
      end

      post confirmations_path, params: {user: {email: email}}

      expect(response).to redirect_to(new_confirmation_path)
      expect(flash[:alert]).to eq('Try again later.')
    end
  end

  describe 'profile email change (reconfirmable)' do
    it 'postpones the change and sends confirmation to the new address' do
      user.confirm!
      sign_in user

      expect { patch profile_path, params: {user: {email: 'newer@person.com'}} }
        .to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)

      user.reload
      expect(user.email).to eq('pending@person.com')
      expect(user.unconfirmed_email).to eq('newer@person.com')
    end
  end
end
