require 'rails_helper'

describe Organizer::TracksController, type: :controller do
  let(:event) { create(:event) }
  before { login(create(:organizer, event: event)) }

  describe "Delete 'destroy'" do
    it "destroys the track with ajax" do
      track = create(:track, event: event)
      expect {
        xhr :delete, :destroy, id: track, event_id: event
      }.to change(Track, :count).by(-1)
      expect(response).to be_success
    end
  end

end
