require 'rails_helper'

describe InternalComment do
  describe "#mention_names" do
    it "finds the mention names" do
      comment = build(:internal_comment, body: "Hello @reviewer!")

      expect(comment.mention_names).to eq(["reviewer"])
    end
  end

  describe "#create" do
    context "when reviewer creates InternalComment" do
      let(:proposal) { create(:proposal, :with_organizer_public_comment, :with_speaker) }
      let!(:speaker) { proposal.speakers.first.user }
      let!(:organizer) { Teammate.for_event(proposal.event).organizer.first.user }
      let!(:organizer2) { create(:organizer) }
      let!(:reviewer) { create(:reviewer, event: proposal.event) }

      describe "for organizers who have commented on the proposal" do
        it "creates a notification to other teammates when reviewer creates internal comment" do

          expect {
            proposal.internal_comments.create(attributes_for(:comment, :internal, user: reviewer))
          }.to change(Notification, :count).by(1)

          expect(Notification.count).to eq(1)
          expect(organizer.notifications.length).to eq(1)
          expect(reviewer.notifications.length).to eq(0)
        end

        it "creates a notification to other teammates and sends an email to the person mentioned when a reviewer mentions a teammate in an internal comment" do
          ActionMailer::Base.deliveries.clear
          expect {
            proposal.internal_comments.create(attributes_for(:comment, :internal, user: reviewer, body: "@#{organizer.teammates.first.mention_name}, this is for you."))
          }.to change(Notification, :count).by(1)
            .and change(ActionMailer::Base.deliveries, :count).by(1)

          expect(Notification.count).to eq(1)
          expect(organizer.notifications.length).to eq(1)
          expect(organizer.notifications.pluck(:message)).to include("#{reviewer.name} mentioned you in a new internal comment")
          expect(reviewer.notifications.length).to eq(0)
        end

        it 'does only creates a notification and no email when teammate preference is in app only' do
          ActionMailer::Base.deliveries.clear
          organizer.teammates.first.update_attributes(notification_preference: Teammate::IN_APP_ONLY)
          expect {
            proposal.internal_comments.create(attributes_for(:comment, :internal, user: reviewer, body: "@#{organizer.teammates.first.mention_name}, this is for you."))
          }.to change(Notification, :count).by(1)
            .and change(ActionMailer::Base.deliveries, :count).by(0)
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
