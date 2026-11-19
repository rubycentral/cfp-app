require 'rails_helper'

describe Admin::EventsController, type: :controller do
  describe "POST #archive" do
    it "archives the event" do
      event = create(:event)
      sign_in(create(:admin))
      post :archive, params: {event_slug: event.slug}
      expect(event.reload).to be_archived
    end
  end
end
