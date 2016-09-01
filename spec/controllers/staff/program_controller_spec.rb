require 'rails_helper'

describe Staff::ProgramController, type: :controller do
  let(:event) { create(:event) }

  describe "GET #show" do
    it "returns http success" do
      pending 'probably going to drop this'
      fail
      # sign_in(create(:organizer, event: event))
      # get :show, event_slug: event
      # expect(response).to be_success
    end
  end
end
