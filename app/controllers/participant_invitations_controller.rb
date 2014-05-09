class ParticipantInvitationsController < ApplicationController
  before_action :set_participant_invitation
  before_action :require_pending
  before_action :require_user, only: :accept

  decorates_assigned :participant_invitation

  def accept
    @participant_invitation.accept
    @participant_invitation.create_participant(current_user)

    redirect_to root_url,
      flash: { info: 'You successfully accepted the invitation' }
  end

  def refuse
    @participant_invitation.refuse
    redirect_to root_url,
      flash: { danger: 'You successfully declined the invitation' }
  end

  private

  def set_participant_invitation
    @participant_invitation = ParticipantInvitation.find_by!(slug: params[:slug],
                                                             token: params[:token])
  end

  def require_pending
    redirect_to root_url unless @participant_invitation.pending?
  end
end
