require 'rails_helper'

describe Admin::EventsController, type: :controller do

  describe "GET #index" do

    it "should succeed" do
      login(create(:admin))
      get :index
      expect(response).to render_template :index
    end
  end

  describe "POST #archive" do
    it "archives the event" do
      login(create(:admin))
      post :archive, event_id: 1
      expect(response).to redirect_to(admin_events_path)
    end
  end
end