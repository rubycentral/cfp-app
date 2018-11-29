class TeammateInvitationMailer < ApplicationMailer

  def create(teammate)
    @teammate = teammate
    @event = teammate.event

    mail_markdown to: teammate.email,
                  from: @event.contact_email,
                  subject: "You've been invited to participate in the #{@event.name} CFP"
  end

end
