require 'rails_helper'

describe NotificationsController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end

    it "redirects an unauthenticated user" do
      sign_out(user)
      get :index
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      notification = create(:notification, user: user)
      get 'show', id: notification
      expect(response).to be_redirect
    end

    it "sets notification as read" do
      notification = create(:notification, read_at: nil, user: user)
      get 'show', id: notification
      expect(notification.reload).to be_read
    end
  end

end
