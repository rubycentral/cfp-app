require "rails_helper"

describe CommentNotificationMailer do
  describe "speaker_notification" do
    let(:proposal) { create(:proposal, :with_reviewer_public_comment) }
    let(:reviewer) { create(:user, :reviewer) }
    let(:comment) { create(:comment, user: reviewer, proposal: proposal) }
    let(:mail) { CommentNotificationMailer.speaker_notification(proposal, comment, proposal.speakers) }

    before :each do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
    end

    it "emails proposal speakers when reviewer comments" do
      expect(mail.to.count).to eq(3)
      expect(mail.to).to match_array(proposal.speakers.map(&:email))
    end

    it "has proper subject" do
      expect(mail.subject).to eq("#{proposal.event.name} CFP: New comment on '#{proposal.title}'")
    end

    it "has proper body content" do
      #Verify format of email and that it includes the event name, proposal title, link to proposal and comment body.
      expect(mail.body.encoded).to match(proposal.event.name)
      expect(mail.body.encoded).to match(proposal.title)
      expect(mail.body.encoded).to match("View your proposal")
      expect(mail.body.encoded).to match("/events/#{proposal.event.slug}/proposals/#{proposal.uuid}")
      expect(mail.body.encoded).to match(comment.body)
    end

  end

  describe "reviewer_notification" do
    let(:proposal) { create(:proposal, :with_reviewer_public_comment) }
    let(:reviewer) { create(:user, :reviewer) }
    let(:comment) { create(:comment, proposal: proposal, type: "PublicComment", user: reviewer, body: "Reviewer comment as a Reviewer on Proposal") }
    let(:speaker) { create(:speaker) }
    let(:speaker_comment) { create(:comment, user: speaker.user, proposal: proposal) }
    let(:mail) { CommentNotificationMailer.reviewer_notification(proposal, speaker_comment, proposal.reviewers) }

    context "As a Reviewer" do
      before :each do
        proposal.save!
        speaker_comment.save!
        comment.save!
      end

      it "emails reviewers when speaker comments" do
        expect(proposal.reviewers.count).to eq(2)
        expect(mail.to.count).to eq(2)
        expect(mail.to).to match_array([proposal.reviewers.first.email, reviewer.email])
      end

      it "has proper subject" do
        expect(mail.subject).to eq("#{proposal.event.name} CFP: New comment on '#{proposal.title}'")
      end

      it "has proper body content" do
        expect(mail.body.encoded).to match(proposal.event.name)
        expect(mail.body.encoded).to match(proposal.title)
        expect(mail.body.encoded).to match("A comment has been left on the proposal '#{proposal.title}' for #{proposal.event.name}:")
        expect(mail.body.encoded).to match("/events/#{proposal.event.slug}/staff/proposals/#{proposal.uuid}")
        expect(mail.body.encoded).to match(speaker_comment.body)
      end
    end
  end

  describe "mention_notification" do
    let(:proposal) { create(:proposal) }
    let(:reviewer) { create(:user, :reviewer) }
    let(:reviewer2) { create(:user, :reviewer) }
    let(:mention) { "@#{reviewer2.teammates.first.mention_name}" }
    let(:comment) { create(:comment, proposal: proposal, type: "InternalComment", user: reviewer, body: "#{mention}, hello.") }
    let(:mail) { CommentNotificationMailer.mention_notification(proposal, comment, reviewer2, mention) }

    context "As a Reviewer" do
      before :each do
        proposal.save!
        comment.save!
      end

      it "emails mentioned teammate when reviewer comments" do
        expect(mail.to.count).to eq(1)
        expect(mail.to).to match([reviewer2.email])
      end

      it "has proper subject" do
        expect(mail.subject).to eq("#{proposal.event.name} CFP: #{comment.user.name} mentioned you on '#{proposal.title}'")
      end

      it "has proper body content" do
        expect(mail.body.encoded).to match(proposal.title)
        expect(mail.body.encoded).to match("#{comment.user.name} mentioned you in an internal comment on the proposal '#{proposal.title}'")
        expect(mail.body.encoded).to match("/events/#{proposal.event.slug}/staff/proposals/#{proposal.uuid}")
        expect(mail.body.encoded).to match(comment.body.gsub(mention, "<strong>#{mention}</strong>"))
      end
    end
  end

end
