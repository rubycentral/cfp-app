require 'rails_helper'

describe PublicComment do
  describe "#create" do
    context "when speaker creates PublicComment" do
      let(:speaker) { proposal.speakers.first.person }

      describe "for organizers who have commented" do
        let(:proposal) { create(:proposal, :with_organizer_public_comment, :with_speaker) }
        let(:organizer) { Participant.for_event(proposal.event).organizer.first.person }
        it "creates a notification" do
          expect {
            proposal.public_comments.create(attributes_for(:comment, person: speaker))
          }.to change {
            organizer.reload.notifications.count
          }.by(1)
        end

        it "does not show the name of the speaker" do
          proposal.public_comments.create(attributes_for(:comment, person: speaker))
          expect(organizer.reload.notifications.last.message).to_not match(speaker.name)
        end
      end

      describe "for reviewers who have commented" do
        let(:proposal) { create(:proposal, :with_reviewer_public_comment, :with_speaker) }
        let(:reviewer) { Participant.for_event(proposal.event).reviewer.first.person }

        it "creates a notification" do
          expect {
            proposal.public_comments.create(attributes_for(:comment, person: speaker))
          }.to change {
            reviewer.reload.notifications.count
          }.by(1)
        end

        it "does not show the name of the speaker" do
          proposal.public_comments.create(attributes_for(:comment, person: speaker))
          expect(reviewer.reload.notifications.last.message).to_not match(speaker.name)
        end
      end

      describe "for organizers who have NOT commented" do
        let(:proposal) { create(:proposal, :with_speaker) }

        it "does not create a notification" do
          organizer = create(:organizer, event: proposal.event)

          expect {
            proposal.public_comments.create(attributes_for(:comment, person: speaker))
          }.to_not change {
            organizer.reload.notifications.count
          }
        end
      end

      describe "for reviewers who have NOT commented" do
        let(:proposal) { create(:proposal, :with_speaker) }

        it "does not create a notification" do
          reviewer = create(:person, :reviewer)

          expect {
            proposal.public_comments.create(attributes_for(:comment, person: speaker))
          }.to_not change {
            reviewer.reload.notifications.count
          }
        end
      end

      describe "for organizers who have commented on a different proposal" do
        let(:proposal) { create(:proposal, :with_speaker) }

        it "does not create a notification" do
          other_proposal = create(:proposal, :with_organizer_public_comment, event: proposal.event)
          reviewer_who_commented = other_proposal.public_comments.first.person

          expect {
            proposal.public_comments.create(attributes_for(:comment, person: speaker))
          }.to_not change {
            reviewer_who_commented.reload.notifications.count
          }
        end
      end

      describe "for organizers who have rated the proposal" do
        it "creates a notification" do
          proposal = create(:proposal, :with_speaker)
          organizer = create(:organizer, event: proposal.event)
          create(:rating, proposal: proposal, person: organizer)

          expect {
            proposal.public_comments.create(attributes_for(:comment, person: proposal.speakers.first.person))
          }.to change(Notification, :count).by(1)

          expect(Notification.last.person).to eq(organizer)
        end
      end
    end

    context "when reviewer creates a PublicComment" do
      it "should send a notification to the speaker" do
        proposal = create(:proposal, :with_speaker)
        reviewer = create(:person, :reviewer)

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: reviewer))
        }.to change(Notification, :count).by(1)

        expect(Notification.last.person).to eq(proposal.speakers.first.person)
      end

      it "should send notication to each speaker" do
        proposal = create(:proposal)
        speakers = create_list(:speaker, 3, proposal: proposal)
        reviewer = create(:person, :reviewer)

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: reviewer))
        }.to change(Notification, :count).by(3)

        speakers.each do |speaker|
          expect(speaker.person.notifications.count).to eq(1)
        end
      end
    end
  end

  describe "#send_emails" do
    context "when reviewer creates a PublicComment" do
      it "should send notication to each speaker" do
        proposal = create(:proposal)
        speakers = create_list(:speaker, 3, proposal: proposal)
        reviewer = create(:person, :reviewer)

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: reviewer))
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        expect(ActionMailer::Base.deliveries.last.bcc).to match_array(speakers.map(&:email))
      end
    end
  end

end
