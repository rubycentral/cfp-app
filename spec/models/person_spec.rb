require 'rails_helper'

describe Person do

  describe ".authenticate" do
    let(:uid) { '123' }
    let(:provider) { 'developer' }
    let(:name) { 'Name' }
    let(:email) { 'name@example.com' }
    let(:auth_hash) do
      {
        'provider' => provider,
        'uid' => uid,
        'info' => {
          'name' => name,
          'email' => email
        }
      }
    end

    context "User already exists" do
      let!(:user) { create(:person) }

      it "doesn't create a new person" do
        expect {
          Person.authenticate(auth_hash, user)
        }.to_not change { Person.count }
      end

      context "Using a new service" do
        it "creates a new service" do
          service, user = nil, nil
          expect {
            service, user = Person.authenticate(auth_hash, user)
          }.to change { Service.count }.by(1)

          expect(service.uemail).to eq(email)
          expect(service.uname).to eq(name)
        end

        it "adds the new service to the user" do
          service, returned_user = Person.authenticate(auth_hash, user)
          expect(user.services).to match_array([service])
        end

        it "returns the provided user" do
          service, returned_user = Person.authenticate(auth_hash, user)
          expect(returned_user).to eq(user)
        end
      end

      context "Using an existing service" do
        let!(:service) {
          create(:service, provider: provider, uid: uid, person: user) }

        it "doesn't create a new service" do
          expect {
            Person.authenticate(auth_hash, user)
          }.to_not change { Service.count }
        end

        it "doesn't add new services to the user" do
          service, user = Person.authenticate(auth_hash, user)
          expect(user.services).to match_array([service])
        end
      end
    end

    context "User doesn't yet exist" do
      it "creates a new person" do
        expect { Person.authenticate(auth_hash) }.to change { Person.count }.by(1)
      end

      it "sets user's email and name" do
        service, user = Person.authenticate(auth_hash)
        expect(user.email).to eq(email)
        expect(user.name).to eq(name)
      end

      it "creates a new service for user" do
        service, user = nil, nil
        expect {
          service, user = Person.authenticate(auth_hash)
        }.to change { Service.count }.by(1)
        expect(user.services).to eq([service])
      end
    end

    context "User doesn't have an email" do
      let(:email) { '' }

      it "creates a new person" do
        expect { Person.authenticate(auth_hash) }.to change { Person.count }.by(1)
      end

      it "sets user's email to nil while still setting name" do
        service, user = Person.authenticate(auth_hash)
        expect(user.email).to eq(nil)
        expect(user.name).to eq(name)
      end
    end
  end

  describe '#new' do
    it 'should default to non-admin' do
      expect(Person.new).not_to be_admin
    end
  end

  describe "#gravatar_hash" do
    it "returns an md5 hash of the email" do
      email = 'name@example.com'
      person = create(:person, email: email)
      expect(person.gravatar_hash).to eq(Digest::MD5.hexdigest(email))
    end
  end

  describe "#connected?" do
    it "returns true for a connected service provider" do
      provider = 'github'
      person = create(:person)
      create(:service, provider: provider, person: person)

      expect(person).to be_connected(provider)
    end

    it "returns false for a non-connected provider" do
      person = create(:person)
      expect(person).to_not be_connected('some_provider')
    end
  end

  describe "#complete?" do
    it "returns true if name and email are present" do
      person = create(:person, name: 'Harry', email: 'harry@hogwarts.edu')
      expect(person).to be_complete
    end

    it "returns false if name is missing" do
      person = create(:person, name: nil, email: 'harry@hogwarts.edu')
      expect(person).to_not be_complete
    end

    it "returns false if email is missing" do
      person = create(:person, name: 'Harry', email: nil)
      expect(person).to_not be_complete
    end
  end

  describe '#reviewer?' do
    let(:person) { create(:person, :reviewer) }

    it 'is true when reviewer for any event' do
      expect(person).to be_reviewer
    end
    it 'is false when not reviewer of any event' do
      person.participants.map { |p| p.update_attribute(:role, 'not_reviewer') }
      expect(person).not_to be_reviewer
    end
  end

  describe '#organizer?' do
    let(:person) { create(:person, :organizer) }

    it 'is true when organizer for any event' do
      expect(person).to be_organizer
    end
    it 'is false when not organizer of any event' do
      person.participants.map { |p| p.update_attribute(:role, 'not_organizer') }
      expect(person).not_to be_organizer
    end
  end

  describe "organizer or reviewer for event" do
    let(:event1) { create(:event) }
    let(:event2) { create(:event) }
    let(:person) { create(:person) }

    describe '#reviewer_for_event?' do
      before do
        create(:participant, event: event1, person: person, role: 'reviewer')
        create(:participant, event: event2, person: person, role: 'not_reviewer')
      end

      it 'is true when reviewer for the event' do
        expect(person).to be_reviewer_for_event(event1)
      end
      it 'is false when not reviewer of the event' do
        expect(person).not_to be_reviewer_for_event(event2)
      end
    end

    describe '#organizer_for_event?' do
      before do
        create(:participant, event: event1, person: person, role: 'organizer')
        create(:participant, event: event2, person: person, role: 'not_organizer')
      end

      it 'is true when organizer for the event' do
        expect(person).to be_organizer_for_event(event1)
      end
      it 'is false when not organizer of the event' do
        expect(person).not_to be_organizer_for_event(event2)
      end
    end
  end

  describe "#rating_for" do
    let(:person) { create(:person) }
    let(:proposal) { create(:proposal) }

    it "returns the proposal's rating if user has rated it" do
      rating = create(:rating, person: person, proposal: proposal)
      expect(person.rating_for(proposal)).to eq(rating)
    end

    it "returns new rating if user has not rated the proposal" do
      rating = person.rating_for(proposal)
      expect(rating).to be
      expect(rating.person).to eq(person)
      expect(rating.proposal).to eq(proposal)
    end
  end

  describe "#role_names" do
    let(:event) { create(:event) }
    let(:person) { create(:person) }
    let!(:participant) {
      create(:participant, role: 'reviewer', event: event, person: person) }

    it "returns the role names for a reviewer" do
      expect(person.role_names).to eq('reviewer')
    end

    it "returns multiple roles" do
      create(:participant, role: 'organizer', event: event, person: person)
      role_names = person.role_names
      expect(role_names).to include('reviewer')
      expect(role_names).to include('organizer')
    end

    it "returns unique roles" do
      event2 = create(:event)
      create(:participant, role: 'reviewer', event: event2, person: person)

      expect(person.role_names).to eq('reviewer')
    end
  end

  describe "#assign_open_invitations" do
    it "assigns open invitations to the person" do
      email = "harry.potter@hogwarts.edu"
      invitation = create(:invitation, email: email,
                          state: Invitation::State::PENDING)
      person = create(:person, email: email)

      person.assign_open_invitations
      expect(invitation.reload.person).to eq(person)
    end
  end
end
