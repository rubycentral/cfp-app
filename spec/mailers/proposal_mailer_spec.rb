require "rails_helper"

describe ProposalMailer do
  describe "comment_notification" do
    let(:proposal) { create(:proposal) }
    let(:person) { create(:person) }
    let(:comment) { create(:comment, person: person, proposal: proposal) }
    let(:mail) { ProposalMailer.comment_notification(proposal, comment) }

    it "bccs to all speakers" do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
      expect(mail.bcc.count).to eq(3)
      expect(mail.bcc).to match_array(proposal.speakers.map(&:email))
    end

    it "doesn't bcc the speaker if they are also the commenter" do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
      proposal.speakers << build(:speaker, person: person)
      expect(proposal.speakers.count).to eq(4)
      expect(mail.bcc.count).to eq(3)
      expect(mail.bcc).to match_array(proposal.speakers.first(3).map(&:email))
    end
  end

end
