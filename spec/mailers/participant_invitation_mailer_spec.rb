require "rails_helper"

describe ParticipantInvitationMailer, type: :mailer do
  describe "create" do
    let(:invitation) { create(:participant_invitation) }
    let(:mail) { ParticipantInvitationMailer.create(invitation) }

    it "renders the headers" do
      expect(mail.subject).to eq("You've been invited to participate in a CFP")
      expect(mail.to).to eq([invitation.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to(
        match(accept_participant_invitation_url(invitation.slug,
          invitation.token)))

      expect(mail.body.encoded).to(
        match(refuse_participant_invitation_url(invitation.slug,
          invitation.token)))

      expect(mail.body.encoded).to match(event_url(invitation.event.slug))
    end
  end

end
