class Staff::TeamInvitationsController < Staff::ApplicationController

  def create
    invitation = current_event.event_teammate_invitations.build(params.require(:team_invitation).permit(:email, :role))

    if invitation.save
      EventTeammateInvitationMailer.create(invitation).deliver_now
      redirect_to event_staff_team_index_path(current_event),
        flash: { info: "Invitation to #{invitation.email} was sent."}
    else
      redirect_to event_staff_team_index_path(current_event),
        flash: { danger: "There was a problem sending your invitation." }
    end
  end

  def destroy
    invitation = current_event.event_teammate_invitations.find(params[:id])
    if invitation.destroy
      redirect_to event_staff_team_index_path(current_event),
        flash: { info: "Invitation to #{invitation.email} was removed." }
    else
      redirect_to event_staff_team_index_path(current_event),
        flash: { danger: "There was a problem removing your invitation." }
    end
  end

end
