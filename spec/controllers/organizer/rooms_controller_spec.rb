require 'rails_helper'

describe Organizer::RoomsController, type: :controller do
  let(:event) { create(:event) }
  before { login(create(:organizer, event: event)) }

  describe "DELETE 'destroy'" do
    it "destroys the room with ajax" do
      room = create(:room, event: event)
      expect {
        xhr :delete, :destroy, id: room, event_id: event
      }.to change(Room, :count).by(-1)
      expect(response).to be_success
    end
  end

end
