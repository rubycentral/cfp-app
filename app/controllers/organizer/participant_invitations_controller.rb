class Organizer::ParticipantInvitationsController < Organizer::ApplicationController
  before_action :set_participant_invitation, only: [ :destroy ]

  decorates_assigned :participant_invitation

  # GET /participant_invitations
  def index
    render locals: {
      participant_invitations: @event.participant_invitations
    }
  end

  # POST /participant_invitations
  def create
    @participant_invitation =
      @event.participant_invitations.build(participant_invitation_params)

    if @participant_invitation.save
      ParticipantInvitationMailer.create(@participant_invitation).deliver_now
      redirect_to organizer_event_participant_invitations_url(@event),
        flash: { info: 'Participant invitation successfully sent.' }
    else
      redirect_to organizer_event_participant_invitations_path(@event),
        flash: { danger: 'There was a problem creating your invitation.' }
    end
  end

  # DELETE /participant_invitations/1
  def destroy
    @participant_invitation.destroy

    redirect_to organizer_event_participant_invitations_url(@event),
      flash: { info: 'Participant invitation was successfully removed.' }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_participant_invitation
      @participant_invitation =
        @event.participant_invitations.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def participant_invitation_params
      params.require(:participant_invitation).permit(:email, :role)
    end
end
