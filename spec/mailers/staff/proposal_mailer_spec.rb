require "rails_helper"

describe Staff::ProposalMailer do
  let(:event) { create(:event) }
  let(:speaker) { create(:speaker) }
  let(:proposal) { create(:proposal, event: event, speakers: [speaker]) }

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe "accept_email" do
    let(:mail) { Staff::ProposalMailer.accept_email(event, proposal) }

    it "emails to all speakers including contact_mail" do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
      expect(mail.to.count).to eq(3)
      bcc_emails = event.contact_email
      expect(mail.bcc).to match_array(bcc_emails)
    end

    it "uses event's accept template" do
      event.update_attribute(:accept, "Body stored in database.")
      mail.deliver_now
      expect(mail.html_part.body.to_s).to eq("<p>Body stored in database.</p>\n")
    end

    it "uses the default template if event's accept is blank" do
      event.update_attribute(:accept, "")
      mail.deliver_now
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Your proposal for #{event} has been accepted")
    end

    it "gives the speaker the ability to submit feedback and ask any questions they may have" do
      proposal.update_attribute(:confirmation_notes, "I love cats")
      expect(proposal.confirmation_notes).to eq("I love cats")
    end
  end

  describe "reject_email" do
    let(:mail) { Staff::ProposalMailer.reject_email(event, proposal) }

    it "bccs to all speakers including contact_mail" do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
      expect(mail.to.count).to eq(3)
      bcc_emails = event.contact_email
      expect(mail.bcc).to match_array(bcc_emails)
    end

    it "uses event's reject template" do
      event.update_attribute(:reject, "Body stored in database.")
      mail.deliver_now
      expect(mail.html_part.body.to_s).to eq("<p>Body stored in database.</p>\n")
    end

    it "uses the default template if event's reject is blank" do
      event.update_attribute(:reject, "")
      mail.deliver_now
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Your proposal for #{event} has not been accepted")
    end
  end

  describe "waitlist_email" do
    let(:mail) { Staff::ProposalMailer.waitlist_email(event, proposal) }

    it "bccs to all speakers including contact_mail" do
      proposal.speakers = build_list(:speaker, 3)
      proposal.save!
      expect(mail.to.count).to eq(3)
      bcc_emails = event.contact_email
      expect(mail.bcc).to match_array(bcc_emails)
    end

    it "uses event's waitlist template" do
      event.update_attribute(:waitlist, "Body stored in database.")
      mail.deliver_now
      expect(mail.html_part.body.to_s).to eq("<p>Body stored in database.</p>\n")
    end

    it "uses the default template if event's waitlist is blank" do
      event.update_attribute(:waitlist, "")
      mail.deliver_now
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Your proposal for #{event} has been added to the waitlist")
    end
  end
end
