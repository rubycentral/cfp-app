require 'rails_helper'

describe User do

  describe ".from_omniauth" do
    let(:uid) { '123456' }
    let(:provider) { 'twitter' }
    let(:twitter_auth_hash) { OmniAuth.config.mock_auth[:twitter] }
    let(:github_auth_hash) { OmniAuth.config.mock_auth[:github] }
    let(:name) { OmniAuth.config.mock_auth[:twitter].info.name }
    let(:email) { 'test@omniuser.com' }
    let(:account_name) { 'testuser' }

    context 'User already exists with legacy provider/uid' do
      let!(:user) { create(:user, email: email, name: OmniAuth.config.mock_auth[:github].info.name, uid: OmniAuth.config.mock_auth[:github].uid, provider: 'github') }

      it 'does not create a new user' do
        expect {
          User.from_omniauth(github_auth_hash)
        }.to_not change { User.count }
      end

      it 'migrates legacy user to identities table' do
        expect {
          User.from_omniauth(github_auth_hash)
        }.to change { Identity.count }.by(1)

        user.reload
        expect(user.identities.find_by(provider: 'github', uid: github_auth_hash.uid)).to be_present
        expect(user.provider).to be_nil
        expect(user.uid).to be_nil
      end
    end

    context "User doesn't yet exist" do
      it "creates a new user" do
        expect { User.from_omniauth(twitter_auth_hash) }.to change { User.count }.by(1)
      end

      it "sets user's email and name" do
        #No email returned by twitter so use github
        user = User.from_omniauth(github_auth_hash)
        expect(user.email).to eq(email)
        expect(user.name).to eq(name)
      end

      it "returns error if password but no email" do
        user = build(:user, email: "")
        expect {
          user.save!
        }.to raise_error "Validation failed: Email can't be blank"
      end

      it "returns no error if password and provider but no email" do
        user = build(:user, email: "", provider: "twitter", uid: "12345678")
        expect {
          user.save!
        }.to_not raise_error
      end

      it "creates a new user with identity" do
        user = nil
        expect {
          user = User.from_omniauth(twitter_auth_hash)
        }.to change { User.count }.by(1)
        expect(user.identities.count).to eq(1)
        expect(user.identities.first.provider).to eq('twitter')
        expect(user.identities.first.uid).to eq(twitter_auth_hash.uid)
      end
    end

    context "User doesn't have an email" do
      let(:email) { "" }

      it "creates a new user" do
        expect { User.from_omniauth(twitter_auth_hash) }.to change { User.count }.by(1)
      end

      it "sets user's email to '' while still setting name for Twitter" do
        user = User.from_omniauth(twitter_auth_hash)
        expect(user.email).to eq("")
        expect(user.name).to eq(name)
      end
    end
  end

  describe '#new' do
    it 'should default to non-admin' do
      expect(User.new).not_to be_admin
    end
  end

  describe "#gravatar_hash" do
    it "returns an md5 hash of the email" do
      email = 'name@example.com'
      user = create(:user, email: email)
      expect(user.gravatar_hash).to eq(Digest::MD5.hexdigest(email))
    end
  end

  describe "#connected?" do
    it "returns true for a connected provider" do
      provider = 'github'
      user = create(:user, provider: provider)
      expect(user).to be_connected(provider)
    end

    it "returns false for a non-connected provider" do
      user = create(:user)
      expect(user).to_not be_connected('some_provider')
    end
  end

  describe '#oauth_providers' do
    it 'returns providers from identities and legacy provider column' do
      user = create(:user, provider: 'twitter')
      user.identities.create!(provider: 'github', uid: '12345')

      expect(user.oauth_providers).to contain_exactly('twitter', 'github')
    end

    it 'returns unique providers' do
      user = create(:user, provider: 'github')
      user.identities.create!(provider: 'github', uid: '12345')

      expect(user.oauth_providers).to eq(['github'])
    end

    it 'returns empty array when no providers' do
      user = create(:user, provider: nil)

      expect(user.oauth_providers).to be_empty
    end
  end

  describe "#complete?" do
    it "returns true if name and email are present, and unconfirmed_email is blank" do
      user = build(:user, name: 'Harry', email: 'harry@hogwarts.edu', unconfirmed_email: nil)
      expect(user).to be_complete
    end

    it "returns false if name is missing" do
      user = build(:user, name: nil, email: 'harry@hogwarts.edu')
      expect(user).to_not be_complete
    end

    it "returns false if email is missing" do
      user = build(:user, name: 'Harry', email: nil)
      expect(user).to_not be_complete
    end

    it "returns false if unconfirmed_email is present" do
      user = build(:user, name: 'Harry', email: 'harry@hogwarts.edu', unconfirmed_email: 'ron@hogwarts.edu')
      expect(user).to_not be_complete
    end
  end

  describe '#reviewer?' do
    let(:user) { create(:user, :reviewer) }

    it 'is true when reviewer for any event' do
      expect(user).to be_reviewer
    end
    it 'is false when not reviewer of any event' do
      user.teammates.destroy_all
      expect(user).not_to be_reviewer
    end
  end

  describe '#organizer?' do
    let(:user) { create(:user, :organizer) }

    it 'is true when organizer for any event' do
      expect(user).to be_organizer
    end
    it 'is false when not organizer of any event' do
      user.teammates.each { |p| p.update_attribute(:role, :reviewer) }
      expect(user).not_to be_organizer
    end
  end

  describe "organizer or reviewer for event" do
    let(:event1) { create(:event) }
    let(:event2) { create(:event) }
    let(:user) { create(:user) }

    describe '#reviewer_for_event?' do
      before do
        create(:teammate, event: event1, user: user, role: :reviewer)
      end

      it 'is true when reviewer for the event' do
        expect(user).to be_reviewer_for_event(event1)
      end
      it 'is false when not reviewer of the event' do
        expect(user).not_to be_reviewer_for_event(event2)
      end
    end

    describe '#organizer_for_event?' do
      before do
        create(:teammate, event: event1, user: user, role: :organizer)
        create(:teammate, event: event2, user: user, role: :reviewer)
      end

      it 'is true when organizer for the event' do
        expect(user).to be_organizer_for_event(event1)
      end
      it 'is false when not organizer of the event' do
        expect(user).not_to be_organizer_for_event(event2)
      end
    end
  end

  describe "#rating_for" do
    let(:user) { create(:user) }
    let(:proposal) { create(:proposal_with_track) }

    it "returns the proposal's rating if user has rated it" do
      rating = create(:rating, user: user, proposal: proposal)
      expect(user.rating_for(proposal)).to eq(rating)
    end

    it "returns new rating if user has not rated the proposal" do
      rating = user.rating_for(proposal)
      expect(rating).to be
      expect(rating.user).to eq(user)
      expect(rating.proposal).to eq(proposal)
    end
  end

  describe "#role_names" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    let!(:teammate) {
      create(:teammate, role: 'reviewer', event: event, user: user) }

    it "returns the role names for a reviewer" do
      expect(user.role_names).to eq('reviewer')
    end

    it "returns multiple roles" do
      create(:teammate, role: 'organizer', event: create(:event), user: user)
      role_names = user.role_names
      expect(role_names).to include('reviewer')
      expect(role_names).to include('organizer')
    end

    it "returns unique roles" do
      event2 = create(:event)
      create(:teammate, role: 'reviewer', event: event2, user: user)

      expect(user.role_names).to eq('reviewer')
    end
  end

  describe "#profile_errors" do
    let(:unconfirmed_email) { 'ron@hogwarts.edu' }
    let(:unconfirmed_email_err_msg) { "#{unconfirmed_email} needs confirmation" }
    let(:blank_err_msg) { "can't be blank" }

    it "returns no errors if name and email are present, and unconfirmed_email is blank" do
      user = build(:user, name: 'Harry', email: 'harry@hogwarts.edu', unconfirmed_email: nil)
      expect(user.profile_errors).to be_empty
    end

    it "returns an error if name is missing" do
      user = build(:user, name: nil, email: 'harry@hogwarts.edu')
      expect(user.profile_errors.messages[:name][0]).to eq blank_err_msg
    end

    it "returns an error if email is missing" do
      user = build(:user, name: 'Harry', email: nil)
      expect(user.profile_errors.messages[:email][0]).to eq blank_err_msg
    end

    it "returns an error if unconfirmed_email is present" do
      user = build(:user, name: 'Harry', email: 'harry@hogwarts.edu', unconfirmed_email: unconfirmed_email)
      expect(user.profile_errors.messages[:email][0]).to eq unconfirmed_email_err_msg
    end

    it "returns multiple errors if name and email are blank" do
      user = build(:user, name: nil, email: '')
      expect(user.profile_errors.messages[:name][0]).to eq blank_err_msg
      expect(user.profile_errors.messages[:email][0]).to eq blank_err_msg
    end

    it "returns unconfirmed email error when email is blank and unconfirmed_email is present" do
      user = build(:user, name: 'Ron', email: '', unconfirmed_email: unconfirmed_email)
      expect(user.profile_errors.messages[:email][0]).to eq unconfirmed_email_err_msg
    end
  end

  describe '#merge_from!' do
    let(:current_user) { create(:user) }
    let(:legacy_user) { create(:user, provider: 'twitter', uid: '12345') }
    let(:event) { create(:event) }
    let(:proposal) { create(:proposal, event: event) }

    it 'transfers all associations and clears legacy OAuth fields' do
      invitation = create(:invitation, user: legacy_user, email: 'test@example.com', proposal: proposal)
      teammate = create(:teammate, user: legacy_user, event: event, role: 'reviewer')
      speaker = create(:speaker, user: legacy_user, proposal: proposal)
      rating = create(:rating, user: legacy_user, proposal: proposal)
      comment = create(:comment, user: legacy_user, proposal: proposal)
      notification = create(:notification, user: legacy_user)

      current_user.merge_from!(legacy_user)

      expect(invitation.reload.user_id).to eq(current_user.id)
      expect(teammate.reload.user_id).to eq(current_user.id)
      expect(speaker.reload.user_id).to eq(current_user.id)
      expect(rating.reload.user_id).to eq(current_user.id)
      expect(comment.reload.user_id).to eq(current_user.id)
      expect(notification.reload.user_id).to eq(current_user.id)

      legacy_user.reload
      expect(legacy_user.provider).to be_nil
      expect(legacy_user.uid).to be_nil
    end
  end

  describe 'email confirmation tokens' do
    let(:user) { create(:user) }

    it 'round-trips a confirmation token' do
      token = user.email_confirmation_token

      expect(User.find_by_email_confirmation_token(token)).to eq(user)
    end

    it 'invalidates the token when the pending email changes' do
      token = user.email_confirmation_token
      user.update_columns(unconfirmed_email: 'else@where.com')

      expect(User.find_by_email_confirmation_token(token)).to be_nil
    end

    it 'rejects a tampered token' do
      expect(User.find_by_email_confirmation_token("#{user.email_confirmation_token}x")).to be_nil
    end
  end

  describe '#confirm!' do
    it 'stamps confirmed_at for a fresh user' do
      user = build(:user)
      user.save!

      expect { user.confirm! }.to change { user.reload.confirmed_at.present? }.from(false).to(true)
    end

    it 'promotes unconfirmed_email into email' do
      user = create(:user)
      user.update_columns(unconfirmed_email: 'new@addr.com')

      user.confirm!

      user.reload
      expect(user.email).to eq('new@addr.com')
      expect(user.unconfirmed_email).to be_nil
    end

    it 'confirms an oauth user with a blank email (no validation off the promotion path)' do
      user = User.new(email: '', provider: 'twitter', password: '12345678', password_confirmation: '12345678')
      user.save(validate: false)

      expect { user.confirm! }.to change { user.reload.confirmed_at.present? }.from(false).to(true)
    end
  end

  describe 'reconfirmable email changes (postpone_email_change?)' do
    it "postpones an unconfirmed user's email change to unconfirmed_email and mails a confirmation" do
      user = build(:user, email: 'original@person.com')
      user.confirmed_at = nil
      user.save!(validate: false)

      expect {
        expect { user.update!(email: 'changed@person.com') }
          .to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)
      }.to change { user.reload.unconfirmed_email }.from(nil).to('changed@person.com')

      expect(user.email).to eq('original@person.com')
    end

    it "postpones an oauth user's first email (blank -> present) instead of applying it directly" do
      user = User.new(email: '', provider: 'twitter', password: '12345678', password_confirmation: '12345678')
      user.save(validate: false)

      expect {
        expect { user.update(email: 'first@person.com') }
          .to have_enqueued_mail(ConfirmationsMailer, :confirmation_instructions)
      }.to change { user.reload.unconfirmed_email }.from(nil).to('first@person.com')

      expect(user.email).to eq('')
    end

    it 'still promotes the pending email via confirm!' do
      user = create(:user, email: 'original@person.com')
      user.update_columns(unconfirmed_email: 'changed@person.com')

      user.confirm!

      user.reload
      expect(user.email).to eq('changed@person.com')
      expect(user.unconfirmed_email).to be_nil
    end

    it 'applies the change directly when skip_reconfirmation! has been called (admin flow)' do
      user = create(:user, email: 'original@person.com')

      user.skip_reconfirmation!
      user.update!(email: 'admin-edited@person.com')

      user.reload
      expect(user.email).to eq('admin-edited@person.com')
      expect(user.unconfirmed_email).to be_nil
    end

    it 'allows validated updates for identity-backed users with a pending first email' do
      user = User.new(email: '', password: '12345678', password_confirmation: '12345678')
      user.identities.build(provider: 'github', uid: '999', account_name: 'x')
      user.save!(validate: false)
      user.update(email: 'first@addr.com') # postponed to unconfirmed_email

      expect(user.update(bio: 'hello')).to be true
    end
  end

  describe 'password storage' do
    it 'stores the bcrypt digest in the password_digest column' do
      user = create(:user, password: 'secret99', password_confirmation: 'secret99')

      expect(user.read_attribute(:password_digest)).to start_with('$2a$')
      expect(user.authenticate('secret99')).to eq(user)
      expect(User.column_names).not_to include('encrypted_password')
    end
  end
end
