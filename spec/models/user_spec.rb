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

    context "User already exists" do
      let!(:user) { create(:user, email: email, name: OmniAuth.config.mock_auth[:github].info.name, uid: OmniAuth.config.mock_auth[:github].uid, provider: "github") }

      it "doesn't create a new user from github auth hash when user exists" do
        expect {
          User.from_omniauth(github_auth_hash)
        }.to_not change { User.count }
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

      it "creates a new user and sets provider for user" do
        user = nil
        expect {
          user = User.from_omniauth(twitter_auth_hash)
        }.to change { User.count }.by(1)
        expect(user.provider).to eq("twitter")
        expect(user.uid).to eq(twitter_auth_hash.uid)
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
      user.teammates.map { |p| p.update_attribute(:role, 'not_reviewer') }
      expect(user).not_to be_reviewer
    end
  end

  describe '#organizer?' do
    let(:user) { create(:user, :organizer) }

    it 'is true when organizer for any event' do
      expect(user).to be_organizer
    end
    it 'is false when not organizer of any event' do
      user.teammates.map { |p| p.update_attribute(:role, 'not_organizer') }
      expect(user).not_to be_organizer
    end
  end

  describe "organizer or reviewer for event" do
    let(:event1) { create(:event) }
    let(:event2) { create(:event) }
    let(:user) { create(:user) }

    describe '#reviewer_for_event?' do
      before do
        create(:teammate, event: event1, user: user, role: 'reviewer')
        create(:teammate, event: event2, user: user, role: 'not_reviewer')
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
        create(:teammate, event: event1, user: user, role: 'organizer')
        create(:teammate, event: event2, user: user, role: 'not_organizer')
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
    let(:proposal) { create(:proposal) }

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
end
