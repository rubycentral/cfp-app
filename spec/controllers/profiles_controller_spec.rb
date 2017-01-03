require 'rails_helper'

describe ProfilesController, type: :controller do
  describe 'GET #edit' do
    let(:user) { create :user }
    let(:action) { :edit }
    let(:params) { {} }

    before { sign_in user }

    context 'user profile is complete' do
      it 'should succeed' do
        get :edit
        expect(response.status).to eq(200)
      end

      it 'does not return a flash warning' do
        get :edit
        expect(flash[:warning]).not_to be_present
      end
    end

    context 'user profile is incomplete' do
      let(:lead_in_msg) { 'Your profile is incomplete. Please correct the following:' }
      let(:trailing_msg) { '.' }

      it_behaves_like 'an incomplete profile notifier'
    end
  end

  describe 'PUT #update' do
    let(:user) { create(:user) }
    let(:params) {
      { user: { bio: 'foo' } }
    }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "updates the user record" do
      put :update, params: params
      expect(response.code).to eq("302")
    end
  end
end
