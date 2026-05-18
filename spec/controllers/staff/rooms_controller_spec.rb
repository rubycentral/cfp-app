require 'rails_helper'

describe Staff::RoomsController, type: :controller do
  let(:event) { create(:event) }
  before { sign_in(create(:organizer, event: event)) }

  describe "DELETE 'destroy'" do
    it "destroys the room with turbo_stream" do
      room = create(:room, event: event)
      expect {
        delete :destroy, params: {id: room, event_slug: event}, as: :turbo_stream
      }.to change(Room, :count).by(-1)
      expect(response).to be_successful
    end
  end
end
