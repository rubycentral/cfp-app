require "rails_helper"

describe ProposalMailer do
  describe "comment_notification" do
    let(:proposal) { create(:proposal) }
    let(:user) { create(:user) }
    let(:comment) { create(:comment, user: user, proposal: proposal) }
    let(:mail) { ProposalMailer.comment_notification(proposal, comment) }

    it "bccs to all speakers" do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
      expect(mail.to.count).to eq(3)
      expect(mail.to).to match_array(proposal.speakers.map(&:email))
    end

    it "doesn't bcc the speaker if they are also the commenter" do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
      proposal.speakers << build(:speaker, user: user)
      expect(proposal.speakers.count).to eq(4)
      expect(mail.to.count).to eq(3)
      expect(mail.to).to match_array(proposal.speakers.first(3).map(&:email))
    end
  end

end
