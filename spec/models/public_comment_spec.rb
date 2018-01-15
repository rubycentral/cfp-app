require 'rails_helper'

describe PublicComment do
  describe "#create" do
    context "when speaker creates PublicComment" do
      let(:speaker) { proposal.speakers.first.user }

      describe "for organizers who have commented" do
        let(:proposal) { create(:proposal, :with_organizer_public_comment, :with_speaker) }
        let(:organizer) { Teammate.for_event(proposal.event).organizer.first.user }
        it "creates a notification" do
          expect {
            proposal.public_comments.create(attributes_for(:comment, user: speaker))
          }.to change {
            organizer.reload.notifications.count
          }.by(1)
        end

        it "does not show the name of the speaker" do
          proposal.public_comments.create(attributes_for(:comment, user: speaker))
          expect(organizer.reload.notifications.last.message).to_not match(speaker.name)
        end
      end

      describe "for reviewers who have commented" do
        let(:proposal) { create(:proposal, :with_reviewer_public_comment, :with_speaker) }
        let(:reviewer) { Teammate.for_event(proposal.event).reviewer.first.user }

        it "creates a notification" do
          expect {
            proposal.public_comments.create(attributes_for(:comment, user: speaker))
          }.to change {
            reviewer.reload.notifications.count
          }.by(1)
        end

        it "does not show the name of the speaker" do
          proposal.public_comments.create(attributes_for(:comment, user: speaker))
          expect(reviewer.reload.notifications.last.message).to_not match(speaker.name)
        end
      end

      describe "for organizers who have NOT commented" do
        let(:proposal) { create(:proposal, :with_speaker) }

        it "does not create a notification" do
          organizer = create(:organizer, event: proposal.event)

          expect {
            proposal.public_comments.create(attributes_for(:comment, user: speaker))
          }.to_not change {
            organizer.reload.notifications.count
          }
        end
      end

      describe "for reviewers who have NOT commented" do
        let(:proposal) { create(:proposal, :with_speaker) }

        it "does not create a notification" do
          reviewer = create(:user, :reviewer)

          expect {
            proposal.public_comments.create(attributes_for(:comment, user: speaker))
          }.to_not change {
            reviewer.reload.notifications.count
          }
        end
      end

      describe "for organizers who have commented on a different proposal" do
        let(:proposal) { create(:proposal, :with_speaker) }

        it "does not create a notification" do
          other_proposal = create(:proposal, :with_organizer_public_comment, event: proposal.event)
          reviewer_who_commented = other_proposal.public_comments.first.user

          expect {
            proposal.public_comments.create(attributes_for(:comment, user: speaker))
          }.to_not change {
            reviewer_who_commented.reload.notifications.count
          }
        end
      end

      describe "for organizers who have rated the proposal" do
        it "creates a notification" do
          proposal = create(:proposal, :with_speaker)
          organizer = create(:organizer, event: proposal.event)
          create(:rating, proposal: proposal, user: organizer)

          expect {
            proposal.public_comments.create(attributes_for(:comment, user: proposal.speakers.first.user))
          }.to change(Notification, :count).by(1)

          expect(Notification.last.user).to eq(organizer)
        end
      end
    end

    context "when reviewer creates a PublicComment" do
      it "should send a notification to the speaker" do
        proposal = create(:proposal, :with_speaker)
        reviewer = create(:user, :reviewer)

        expect {
          proposal.public_comments.create(attributes_for(:comment, user: reviewer))
        }.to change(Notification, :count).by(1)

        expect(Notification.last.user).to eq(proposal.speakers.first.user)
      end

      it "should send notication to each speaker" do
        proposal = create(:proposal)
        speakers = create_list(:speaker, 3, proposal: proposal)
        reviewer = create(:user, :reviewer)

        expect {
          proposal.public_comments.create(attributes_for(:comment, user: reviewer))
        }.to change(Notification, :count).by(3)

        speakers.each do |speaker|
          expect(speaker.user.notifications.count).to eq(1)
        end
      end
    end
  end

  describe "#send_emails" do
    let!(:proposal) { create(:proposal) }
    let!(:speakers) { create_list(:speaker, 3, proposal: proposal) }
    let!(:reviewer) { create(:user, :reviewer) }
    context "when reviewer creates a PublicComment" do
      it "should send notication to each speaker" do
        expect {
          proposal.public_comments.create(attributes_for(:comment, user: reviewer))
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        expect(ActionMailer::Base.deliveries.last.to).to match_array(speakers.map(&:email))
      end
    end

    context 'Speaker create a PublicComment' do
      before { proposal.public_comments.create(attributes_for(:comment, user: reviewer)) }
      it 'should send notification to reviewer if speaker comments' do
        expect {
          proposal.public_comments.create(attributes_for(:comment, user: speakers.first.user))
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        expect(ActionMailer::Base.deliveries.last.to).to match_array([reviewer.email])
      end

      it 'should not send notification if reviewer has turned off email notifications' do
        reviewer.teammates.first.update_attribute(:notification_preference, Teammate::IN_APP_ONLY)
        expect {
          proposal.public_comments.create(attributes_for(:comment, user: speakers.first.user))
        }.to change(ActionMailer::Base.deliveries, :count).by(0)
      end
    end
  end

end
