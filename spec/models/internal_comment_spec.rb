require 'rails_helper'

describe InternalComment do
  describe "#create" do
    context "when reviewer creates InternalComment" do
      let(:proposal) { create(:proposal, :with_organizer_public_comment, :with_speaker) }
      let(:speaker) { proposal.speakers.first.user }
      let(:organizer) { Teammate.for_event(proposal.event).organizer.first.user }
      let(:organizer2) { create(:organizer) }
      let(:reviewer) { create(:reviewer, event: proposal.event) }

      describe "for organizers who have commented on the proposal" do
        it "creates a notification to other teammates when reviewer creates internal comment" do

          expect {
            proposal.internal_comments.create(attributes_for(:comment, :internal, user: reviewer))
          }.to change(Notification, :count).by(1)

          expect(Notification.count).to eq(1)
          expect(organizer.notifications.length).to eq(1)
          expect(reviewer.notifications.length).to eq(0)
        end

        it "creates notifications for all teammates when reviewer comments" do
          create(:comment, proposal: proposal, type: "PublicComment", user: organizer2, body: "Organizer 2 comment" )

          expect {
            proposal.internal_comments.create(attributes_for(:comment, :internal, user: reviewer))
          }.to change(Notification, :count).by(2)

          expect(organizer.notifications.length).to eq(1)
          expect(organizer2.notifications.length).to eq(1)
        end

      end
    end
  end

end
