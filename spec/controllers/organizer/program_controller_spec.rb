require 'rails_helper'

describe Organizer::ProgramController, type: :controller do
  let(:event) { create(:event) }

  describe "GET #show" do
    it "returns http success" do
      login(create(:organizer, event: event))
      get :show, event_id: event
      expect(response).to be_success
    end
  end
end
