require 'rails_helper'

feature 'Speaker Invitation received' do
  let(:event) { create(:event, state: 'open') }
  let(:proposal) { create(:proposal,
                          title: 'Hello there',
                          abstract: 'Well then.',
                          event: event)
  }
  let!(:knownguy_invitation) { create(:invitation,
                             proposal: proposal,
                             email: known_user.email)
  }
  let!(:newguy_invitation) { create(:invitation,
                                   proposal: proposal,
                                   email: "newguy@speak.er")
  }
  let(:known_user) { create(:user, email: "second@speak.er", password: "12345678") }

  context "User who is not signed in" do
    describe "clicks on the invitation url" do
      before(:each) do
        visit invitation_url(knownguy_invitation.slug)
      end

      it "shows the proposal" do
        expect(page).to have_text(proposal.title)
      end

      it "shows the invitation" do
        expect(page).to have_content("You have been invited to be a speaker for the talk outlined below. Would you like to participate?")
      end

      it "shows the accept & decline buttons" do
        expect(page).to have_link("Accept")
        expect(page).to have_link("Decline")
      end
    end

    describe "accepts invitation" do
      it "is redirected to the login page with a message" do
        visit invitation_url(knownguy_invitation.slug)
        click_link "Accept"
        expect(page).to have_content("To accept your invitation, you must log in or create an account.")
        expect(current_path).to eq(new_user_session_path)
      end

      describe "signs in to complete the process" do
        before(:each) do
          visit invitation_url(knownguy_invitation.slug)
          click_link "Accept"
        end

        it "can signin with a regular account" do
          signin("second@speak.er", "12345678")
          expect(page).to have_content("You have accepted your invitation!")
        end

        it "can signin with a twitter oauth account" do
          known_user.provider = OmniAuth.config.mock_auth[:twitter][:provider]
          known_user.uid = OmniAuth.config.mock_auth[:twitter][:uid]
          known_user.save

          click_link "Sign in with Twitter"
          expect(page).to have_content("You have accepted your invitation!")
        end

        it "can signin with a github oauth account" do
          known_user.provider = OmniAuth.config.mock_auth[:github][:provider]
          known_user.uid = OmniAuth.config.mock_auth[:github][:uid]
          known_user.save

          click_link "Sign in with Github"
          expect(page).to have_content("You have accepted your invitation!")
        end

        it "is redirected to profile page after signin" do
          signin("second@speak.er", "12345678")
          expect(current_path).to eq(edit_profile_path)
          expect(page).to have_content("You have accepted your invitation!")
        end
      end

      describe "creates an account to complete the process" do
        before(:each) do
          visit invitation_url(newguy_invitation.slug)
          click_link "Accept"
        end

        it "can use a regular account" do
          click_link "Sign up"
          sign_up_with("newguy@speak.er", "apples", "apples")
          expect(page).to have_content("You have accepted your invitation!")
        end

        it "can use a twitter oauth account" do
          click_link "Sign up"
          click_link "Sign in with Twitter"
          expect(page).to have_content("You have accepted your invitation!")
        end

        it "can use a github oauth account" do
          click_link "Sign up"
          click_link "Sign in with Github"
          expect(page).to have_content("You have accepted your invitation!")
        end

        it "must complete profile if name missing" do
          click_link "Sign up"
          sign_up_with("newguy@speak.er", "apples", "apples")
          expect(page).to have_content("Before continuing, please take a moment to make sure your profile is complete.")
          expect(current_path).to eq(edit_profile_path)
        end

        it "must complete profile if name missing from oauth hash" do
          OmniAuth.config.mock_auth[:twitter][:info].delete(:name)
          click_link "Sign in with Twitter"
          expect(page).to have_content("Before continuing, please take a moment to make sure your profile is complete.")
          expect(current_path).to eq(edit_profile_path)
        end

        it "is redirected to proposal page after completing profile" do
          click_link "Sign up"
          sign_up_with("newguy@speak.er", "apples", "apples")
          fill_in "Name", with: "A. Paul"
          click_button "Save"
          expect(current_path).to eq(event_proposal_path(event.slug, proposal))
        end

        it "must confirm email first if new account email doesn't match invitation email" do
          click_link "Sign up"
          sign_up_with("new57@per.son", "apples", "apples")
          expect(page).to have_content("A message with a confirmation link has been sent to your email address")
          expect(current_path).to eq(event_path(event))
        end

        it "can complete process after email is confirmed" do
          click_link "Sign up"
          sign_up_with("new57@per.son", "apples", "apples")
          user = User.find_by!(email: "new57@per.son")
          visit user_confirmation_path(confirmation_token: user.confirmation_token)
          signin("new57@per.son", "apples")

          expect(page).to have_content("You have accepted your invitation! Before continuing, please take a moment to make sure your profile is complete.")
          expect(current_path).to eq(edit_profile_path)

          fill_in "Name", with: "A. Paul"
          click_button "Save"
          expect(current_path).to eq(event_proposal_path(event.slug, proposal))
        end

        it "will skip email confirmation if new account email matches invitation email" do
          click_link "Sign up"
          sign_up_with("newguy@speak.er", "apples", "apples")
          expect(page).to_not have_content("A message with a confirmation link has been sent to your email address")
        end
      end
    end

    it "can decline the invitiation" do
      visit invitation_url(knownguy_invitation.slug)
      click_link "Decline"
      expect(page).to have_content("You have declined this invitation.")
    end
  end

  context "User who is signed in" do
    before :each do
      signin("second@speak.er", "12345678")
    end

    describe "clicks on the invitation url" do
      before(:each) do
        visit invitation_url(knownguy_invitation.slug)
      end

      it "shows the proposal" do
        expect(page).to have_text(proposal.title)
      end

      it "shows the invitation" do
        expect(page).to have_content("You have been invited to be a speaker for the talk outlined below. Would you like to participate?")
      end

      it "shows the accept & decline buttons" do
        expect(page).to have_link("Accept")
        expect(page).to have_link("Decline")
      end

      describe "accepts invitation" do
        it "instantly becomes a speaker for the proposal and is redirected to the profile page" do
          click_link "Accept"
          expect(page).to have_content("You have accepted your invitation!")
          expect(current_path).to eq(edit_profile_path)
        end
      end
    end

    it "can decline the invitiation" do
      visit invitation_url(knownguy_invitation.slug)
      click_link "Decline"
      expect(page).to have_content("You have declined this invitation.")
    end

    it "shows the invitation on the My Proposals page" do
      visit proposals_path
      within('div.invitations') do
        expect(page).to have_text(proposal.title)
      end
    end
  end

  context "Token is invalid or invitation can't be found" do
    it "shows a custom 404 error" do
      visit invitation_url(newguy_invitation.slug + "bananas")
      expect(page).to have_text("Oh My. A 404 error. Your confirmation invite link is missing or wrong.")
      expect(page).to have_text("Events")
    end
  end
end
