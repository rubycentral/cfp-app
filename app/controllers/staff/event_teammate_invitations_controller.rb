class Staff::EventTeammateInvitationsController < Staff::ApplicationController
  before_action :set_event_teammate_invitation, only: [ :destroy ]

  decorates_assigned :event_teammate_invitation

  # GET /event_teammate_invitations
  def index
    render locals: {
      event_teammate_invitations: @event.event_teammate_invitations
    }
  end

  # POST /event_teammate_invitations
  def create
    @event_teammate_invitation =
      @event.event_teammate_invitations.build(event_teammate_invitation_params)

    if @event_teammate_invitation.save
      EventTeammateInvitationMailer.create(@event_teammate_invitation).deliver_now
      redirect_to event_staff_event_teammate_invitations_url(@event),
        flash: { info: 'Event teammate invitation successfully sent.' }
    else
      redirect_to event_staff_event_teammate_invitations_path(@event),
        flash: { danger: 'There was a problem creating your invitation.' }
    end
  end

  # DELETE /event_teammate_invitations/1
  def destroy
    @event_teammate_invitation.destroy

    redirect_to event_staff_event_teammate_invitations_url(@event),
      flash: { info: 'Event teammate invitation was successfully removed.' }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_teammate_invitation
      @event_teammate_invitation =
        @event.event_teammate_invitations.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_teammate_invitation_params
      params.require(:event_teammate_invitation).permit(:email, :role)
    end
end
