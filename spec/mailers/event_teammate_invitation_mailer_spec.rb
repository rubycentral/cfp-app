require "rails_helper"

describe EventTeammateInvitationMailer, type: :mailer do
  describe "create" do
    let(:invitation) { create(:event_teammate_invitation) }
    let(:mail) { EventTeammateInvitationMailer.create(invitation) }

    it "renders the headers" do
      expect(mail.subject).to eq("You've been invited to participate in a CFP")
      expect(mail.to).to eq([invitation.email])
    end


    it "renders the body" do
      expect(mail.body.encoded).to(
        match(accept_event_teammate_invitation_url(invitation.slug,
          invitation.token)))

      expect(mail.body.encoded).to(
        match(refuse_event_teammate_invitation_url(invitation.slug,
          invitation.token)))

      expect(mail.body.encoded).to match(event_url(invitation.event.slug))
    end
  end

end
