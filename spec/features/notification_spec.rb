require 'rails_helper'

feature "User's can interact with notifications" do
  let!(:user) { create(:user) }
  let!(:notification) { create(:notification, :unread, message: 'new message', user: user) }

  context "an authenticated user" do
    before { login_as(user) }

    context "in the navbar and notifications dropdown" do
      scenario "can see notifications link if no unread notifications" do
        notification.mark_as_read
        visit root_path
        within ".navbar" do
          expect(page).to have_link("", href: "/notifications")
        end

        within ".badge" do
          expect(page).to_not have_content("1")
        end
      end

      scenario "can see notifications count if unread notifications exist" do
        visit root_path
        within ".navbar" do
          expect(page).to have_link("", href: "/notifications")
          expect(page).to have_content("1")
        end
      end

      scenario "can see only last 10 notifications and can click in dropdown to mark unread/view" do
        10.times do |i|
          create(:notification, :unread, message: "Notice #{i}", target_path: "/events?redir=true", user: user)
        end

        visit root_path
        within ".navbar" do
          expect(page).to have_link("", href: "/notifications")
          expect(page).to have_content("1")
          click_link("Notifications Toggle")
        end

        expect(page).to_not have_content(notification.message)
        10.times do |i|
          expect(page).to have_content("Notice #{i}")
        end
        click_link("Notice 1")
        expect(current_url).to eq("http://www.example.com/events?redir=true")
      end

      scenario "can view all their notifications from dropdown link" do
        visit root_path
        within ".navbar" do
          click_link("Notifications Toggle")
          click_link("View all notifications")
        end

        expect(current_path).to eq(notifications_path)
      end

      scenario "can mark all notifications as read from dropdown link" do
        expect(user.notifications.unread.length).to eq(1)
        visit root_path
        within ".navbar" do
          click_link("Mark all as read")
        end
        expect(user.notifications.unread.length).to eq(0)
      end

      scenario "can see there are more unread notifications in dropdown link" do
        10.times do |i|
          create(:notification, :unread, message: "Notice #{i}", target_path: "/events?redir=true", user: user)
        end

        expect(user.notifications.unread.length).to eq(11)
        visit root_path
        within ".navbar" do
          click_link("1 More Unread")
        end

        expect(current_path).to eq(notifications_path)
      end
    end

    context "on the notifications page" do

      scenario "can view their notifications" do
        visit notifications_path
        expect(page).to have_text("Notifications")
        expect(page).to have_text(notification.message)
      end

      scenario "can mark all as read" do
        visit notifications_path
        expect(user.notifications.unread.length).to eq(1)
        within ".page-header" do
          click_link "Mark all as read"
        end
        expect(current_path).to eq(notifications_path)
        expect(user.notifications.unread.length).to eq(0)
      end

      scenario "can click a notification to see and it is automatically marked as read" do
        visit notifications_path
        expect(user.notifications.unread.length).to eq(1)
        within ".widget-table" do
          click_link "Show"
        end
        expect(current_path).to eq(notification.target_path)
        expect(user.notifications.unread.length).to eq(0)
      end
    end

  end
end
