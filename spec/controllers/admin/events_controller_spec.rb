require 'rails_helper'

describe Admin::EventsController, type: :controller do

  describe "GET #index" do

    it "should succeed" do
      sign_in(create(:admin))
      get :index
      expect(response).to render_template :index
    end
  end

  describe "POST #archive" do
    before :each do
      @event = create(:event)
    end

    it "archives the event" do
      sign_in(create(:admin))
      post :archive, params: {event_slug: @event.slug}
      expect(response).to redirect_to(admin_events_path)
    end
  end
end
