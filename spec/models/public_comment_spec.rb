require 'spec_helper'

describe PublicComment do

  describe "#create" do

    context "when speaker creates PublicComment" do

      it "should should create Notification for organizers" do
        proposal = create(:proposal, :with_organizer_public_comment, :with_speaker)
        organizer = Participant.for_event(proposal.event).organizer.first.person

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: proposal.speakers.first.person))
        }.to change(Notification, :count).by(1)

        expect(Notification.last.person).to eq(organizer)
      end

      it "should should create Notification for reviewers" do
        proposal = create(:proposal, :with_reviewer_public_comment, :with_speaker)
        reviewer = Participant.for_event(proposal.event).reviewer.first.person

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: proposal.speakers.first.person))
        }.to change(Notification, :count).by(1)

        expect(Notification.last.person).to eq(reviewer)
      end

      it "should not create a notification for an organizer who hasn't commented" do
        proposal = create(:proposal, :with_speaker)
        create(:organizer, event: proposal.event)

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: proposal.speakers.first.person))
        }.to_not change(Notification, :count)
      end

      it "should not create a notification for a reviewer who hasn't commented" do
        proposal = create(:proposal, :with_speaker)
        create(:person, :reviewer)

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: proposal.speakers.first.person))
        }.to_not change(Notification, :count)
      end

      it "should not notify an organizer who has commented on a different proposal" do
        proposal = create(:proposal, :with_speaker)
        create(:proposal, :with_organizer_public_comment, event: proposal.event)

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: proposal.speakers.first.person))
        }.to_not change(Notification, :count)
      end

      it "should notify an organizer who has rated a proposal" do
        proposal = create(:proposal, :with_speaker)
        organizer = create(:organizer, event: proposal.event)
        create(:rating, proposal: proposal, person: organizer)

        expect {
          proposal.public_comments.create(attributes_for(:comment, person: proposal.speakers.first.person))
        }.to change(Notification, :count).by(1)

        expect(Notification.last.person).to eq(organizer)
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
