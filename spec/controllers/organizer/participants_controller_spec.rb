require 'rails_helper'

describe Organizer::ParticipantsController, type: :controller do
  describe 'POST #create' do
    let(:event) { create(:event) }
    let(:organizer_user) { create(:person) }
    let!(:organizer_participant) { create(:participant,
                                         event: event,
                                         person: organizer_user,
                                         role: 'organizer')
    }
    let!(:other_user) { create(:person, email: 'foo@bar.com') }


    context "A valid organizer" do
      before { allow(controller).to receive(:current_user).and_return(organizer_user) }

      it "creates a new participant" do
        post :create, participant: { role: 'reviewer' }, email: 'foo@bar.com', event_id: event.id
        expect(event.reload.participants.count).to eql(2)
      end

      it "can retrieve autocompleted emails" do
        email = 'name@example.com'
        create(:person, email: email)
        get :emails, event_id: event, term: 'n', format: :json
        expect(response.body).to include(email)
      end

      it "cannot set a participant's id" do
        post :create, participant: { id: 1337, role: 'reviewer' },
          email: 'foo@bar.com', event_id: event.id
        expect(Participant.last).to_not eq(1337)
      end
    end

    context "A non-organizer" do
      before { allow(controller).to receive(:current_user).and_return(other_user) }

      it "returns 404" do
        expect {
          post :create, participant: { role: 'reviewer' },
            email: 'something@else.com', event_id: event.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "An unauthorized organizer" do
      let(:event2) { create(:event) }
      let(:sneaky_organizer) { create(:person) }

      before do
        create(:participant, person: sneaky_organizer, event: event2,
               role: 'organizer')
        allow(controller).to receive(:current_user).and_return(sneaky_organizer)
      end

      it "cannot create participants for different events" do
        expect {
          post :create, participant: { role: 'organizer' },
            email: sneaky_organizer.email, event_id: event.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

