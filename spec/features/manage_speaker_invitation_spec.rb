require 'rails_helper'

feature 'Managing Speaker Invitations' do
  let(:second_speaker_email) { 'second_speaker@example.com' }
  let(:user) { create(:user) }
  let(:event) { create(:event, state: 'open') }
  let(:proposal) { create(:proposal,
                          title: 'Hello there',
                          abstract: 'Well then.',
                          event: event)
  }
  let!(:speaker) { create(:speaker,
                         user: user,
                         event: event,
                         proposal: proposal)
  }

  let(:go_to_proposal) {
    login_as(user)
    visit(event_proposal_path(event_slug: proposal.event.slug, uuid: proposal))
  }

  context "Creating an invitation" do
    before :each do
      go_to_proposal
      click_on "Invite a Speaker"
      fill_in "Email", with: second_speaker_email
    end

    scenario "A speaker can invite another speaker" do
      click_button "Invite"
      expect(page).
        to(have_text(second_speaker_email))
    end

    it "emails the pending speaker" do
      ActionMailer::Base.deliveries.clear
      click_button "Invite"
      expect(ActionMailer::Base.deliveries.first.to).to include(second_speaker_email)
    end

    scenario "A speaker can re-invite the same speaker" do
      click_button "Invite"
      fill_in "Email", with: second_speaker_email
      click_button "Invite"
      expect(page).
        to(have_text(second_speaker_email))
    end
  end

  context "Removing an invitation" do
    let!(:invitation) { create(:invitation, proposal: proposal, email: second_speaker_email) }

    scenario "A speaker can remove an invitation" do
      go_to_proposal
      click_link "Remove"
      expect(proposal.reload.invitations).not_to include(invitation)
    end
  end

  context "Resending an invitation" do
    let!(:invitation) { create(:invitation, proposal: proposal, email: second_speaker_email) }
    after { ActionMailer::Base.deliveries.clear }

    scenario "A speaker can resend an invitation" do
      go_to_proposal
      click_link "Resend"
      expect(ActionMailer::Base.deliveries.last.to).to include(second_speaker_email)
    end
  end

end
