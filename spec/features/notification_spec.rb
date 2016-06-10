require 'rails_helper'

feature "User's can interact with notifications" do
  let!(:user) { create(:user) }
  let!(:notification) {
    create(:notification, message: 'a new message', user: user) }

  context "an authenticated user" do
    before { login_user(user) }

    it "can view their notifications" do
      visit notifications_path
      expect(page).to have_text("Notifications")
      expect(page).to have_text(notification.message)
    end
  end
end
