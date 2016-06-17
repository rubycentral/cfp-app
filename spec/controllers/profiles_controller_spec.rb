require 'rails_helper'

describe ProfilesController, type: :controller do
  describe 'PUT #update' do
    let(:user) { create(:user) }
    let(:params) {
      { user: { bio: 'foo', demographics: { gender: 'female' } } }
    }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "updates the user record" do
      put :update, params
      expect(response.code).to eq("302")
    end
  end
end
