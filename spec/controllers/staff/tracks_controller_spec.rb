require 'rails_helper'

describe Staff::TracksController, type: :controller do
  let(:event) { create(:event) }
  before { sign_in(create(:organizer, event: event)) }

  describe "Delete 'destroy'" do
    it "destroys the track" do
      pending('Fix once flows are more settled.')
      fail
    end
  end

end
