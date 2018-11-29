require "rails_helper"

describe TeammateInvitationMailer, type: :mailer do

  describe "create" do
    let(:invitation) { create(:teammate, :has_been_invited) }

    let(:mail) { TeammateInvitationMailer.create(invitation) }

    it "renders the headers" do
      event = Event.find_by(id: invitation.event_id)

      expect(mail.subject).to eq("You've been invited to participate in the #{event.name} CFP")

      expect(mail.to).to eq([invitation.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to(match(invitation.mention_name))

      expect(mail.body.encoded).to(match(accept_teammate_url(invitation.token)))

      expect(mail.body.encoded).to(match(decline_teammate_url(invitation.token)))

      expect(mail.body.encoded).to match(event_url(invitation.event.slug))
    end
  end

end
