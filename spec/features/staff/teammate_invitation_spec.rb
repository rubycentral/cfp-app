require 'rails_helper'

feature "Teammate Invitation received" do
  let(:event) { create(:event, name: "My Event") }

  let(:newguy_invitation) { create(:teammate, :has_been_invited, event: event, email: "new@per.son") }
  let(:knownguy_invitation) { create(:teammate, :has_been_invited, event: event, email: "known@per.son") }

  let!(:known_user) { create(:user, email: "known@per.son", password: "12345678") }

  context "User who is not signed in" do
    describe "accepts invitation" do

      it "is redirected to the login page with a message" do
        visit accept_teammate_path(knownguy_invitation.token)
        expect(page).to have_content("To accept your invitation, you must log in or create an account.")
        expect(current_path).to eq(new_user_session_path)
      end

      describe "signs in to complete the process" do
        before(:each) do
          visit accept_teammate_path(knownguy_invitation.token)
        end

        it "can signin with a regular account" do
          signin("known@per.son", "12345678")
          expect(page).to have_content("Congrats! You are now an official team member of My Event!")
        end

        it "can signin with a twitter oauth account" do
          known_user.provider = OmniAuth.config.mock_auth[:twitter][:provider]
          known_user.uid = OmniAuth.config.mock_auth[:twitter][:uid]
          known_user.save

          click_link "Sign in with Twitter"
          expect(page).to have_content("Congrats! You are now an official team member of My Event!")
        end

        it "can signin with a github oauth account" do
          known_user.provider = OmniAuth.config.mock_auth[:github][:provider]
          known_user.uid = OmniAuth.config.mock_auth[:github][:uid]
          known_user.save

          click_link "Sign in with Github"
          expect(page).to have_content("Congrats! You are now an official team member of My Event!")
        end

        it "is redirected to profile page after signin" do
          signin("known@per.son", "12345678")
          expect(current_path).to eq(edit_profile_path)
          expect(page).to have_content("Congrats! You are now an official team member of My Event!")
        end
      end

      describe "creates an account to complete the process" do
        before(:each) do
          visit accept_teammate_path(newguy_invitation.token)
        end

        it "can use a regular account" do
          click_link "Sign up"
          sign_up_with("new@per.son", "apples", "apples")
          expect(page).to have_content("Congrats! You are now an official team member of My Event!")
        end

        it "can use a twitter oauth account" do
          click_link "Sign up"
          click_link "Sign in with Twitter"
          expect(page).to have_content("Congrats! You are now an official team member of My Event!")
        end

        it "can use a github oauth account" do
          click_link "Sign up"
          click_link "Sign in with Github"
          expect(page).to have_content("Congrats! You are now an official team member of My Event!")
        end

        it "must complete profile if name missing" do
          click_link "Sign up"
          sign_up_with("new@per.son", "apples", "apples")
          expect(page).to have_content("Before continuing, please take a moment to make sure your profile is complete.")
          expect(current_path).to eq(edit_profile_path)
        end

        it "must complete profile if name missing from oauth hash" do
          OmniAuth.config.mock_auth[:twitter][:info].delete(:name)
          click_link "Sign in with Twitter"
          expect(page).to have_content("Before continuing, please take a moment to make sure your profile is complete.")
          expect(current_path).to eq(edit_profile_path)
        end

        it "is redirected to team page after completing profile" do
          click_link "Sign up"
          sign_up_with("new@per.son", "apples", "apples")
          fill_in "Name", with: "A. Paul"
          click_button "Save"
          expect(current_path).to eq(event_staff_path(event))
        end

        it "must confirm email first if new account email doesn't match invitation email" do
          click_link "Sign up"
          sign_up_with("new57@per.son", "apples", "apples")
          expect(page).to have_content("A message with a confirmation link has been sent to your email address")
          expect(current_path).to eq(events_path)
        end

        it "can complete process after email is confirmed" do
          click_link "Sign up"
          sign_up_with("new57@per.son", "apples", "apples")
          user = User.find_by!(email: "new57@per.son")
          visit user_confirmation_path(confirmation_token: user.confirmation_token)
          signin("new57@per.son", "apples")

          expect(page).to have_content("Congrats! You are now an official team member of My Event! Before continuing, please take a moment to make sure your profile is complete.")
          expect(current_path).to eq(edit_profile_path)

          fill_in "Name", with: "A. Paul"
          click_button "Save"
          expect(current_path).to eq(event_staff_path(event))
        end

        it "will skip email confirmation if new account email matches invitation email" do
          click_link "Sign up"
          sign_up_with("new@per.son", "apples", "apples")
          expect(page).to_not have_content("A message with a confirmation link has been sent to your email address")
        end
      end
    end

    it "can decline the invitiation" do
      visit decline_teammate_path(newguy_invitation.token)
      expect(page).to have_content("You declined the invitation to #{newguy_invitation.event.name}.")
    end
  end

  context "User who is signed in" do
    before(:each) do
      signin("known@per.son", "12345678")
    end

    describe "accepts invitation" do
      it "instantly becomes a teammate and is redirected to the profile page" do
        visit accept_teammate_path(knownguy_invitation.token)
        expect(page).to have_content("Congrats! You are now an official team member of #{knownguy_invitation.event.name}!")
        expect(current_path).to eq(edit_profile_path)
      end
    end

    it "can decline the invitation" do
      visit decline_teammate_path(knownguy_invitation.token)
      expect(page).to have_content("You declined the invitation to #{newguy_invitation.event.name}.")
    end
  end

  context "Token is invalid or invitation can't be found" do
    it "shows a custom 404 error" do
      visit accept_teammate_path(newguy_invitation.token + "bananas")
      expect(page).to have_text("Oh My. A 404 error. Your confirmation invite link is missing or wrong.")
      expect(page).to have_text("Events")
    end
  end

end
