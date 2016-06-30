require 'rails_helper'

describe Staff::EventTeammatesController, type: :controller do
  describe 'POST #create' do
    let(:event) { create(:event) }
    let(:organizer_user) { create(:user) }
    let!(:organizer_event_teammate) { create(:event_teammate,
                                         event: event,
                                         user: organizer_user,
                                         role: 'organizer')
    }
    let!(:other_user) { create(:user, email: 'foo@bar.com') }


    context "A valid organizer" do
      before { allow(controller).to receive(:current_user).and_return(organizer_user) }

      it "creates a new event_teammate" do
        expect {
          post :create, event_teammate: { role: 'reviewer' },
            email: 'foo@bar.com', event_slug: event.slug
        }.to change{EventTeammate.count}.from(1).to(2)
      end

      it "can retrieve autocompleted emails" do
        email = 'name@example.com'
        create(:user, email: email)
        get :emails, event_slug: event, term: 'n', format: :json
        expect(response.body).to include(email)
      end

      it "cannot set a event_teammate's id" do
        post :create, event_teammate: { id: 1337, role: 'reviewer' },
          email: 'foo@bar.com', event_slug: event.slug
        expect(EventTeammate.last).to_not eq(1337)
      end
    end

    context "A non-organizer" do
      before { allow(controller).to receive(:current_user).and_return(other_user) }

      it "does not change EventTeammate Count" do
        expect {
          post :create, event_teammate: { role: 'reviewer' },
            email: 'something@else.com', event_slug: event.slug
        }.to_not change{EventTeammate.count}
      end
    end

    context "An unauthorized organizer" do
      let(:event2) { create(:event) }
      let(:sneaky_organizer) { create(:user) }

      before do
        create(:event_teammate, user: sneaky_organizer, event: event2,
               role: 'organizer')
        allow(controller).to receive(:current_user).and_return(sneaky_organizer)
      end

      it "cannot create event_teammates for different events" do
        expect {
          post :create, event_teammate: { role: 'organizer' },
            email: sneaky_organizer.email, event_slug: event.slug
        }.to_not change{EventTeammate.count}
      end
    end
  end
end

