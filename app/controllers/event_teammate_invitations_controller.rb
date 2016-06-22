class EventTeammateInvitationsController < ApplicationController
  before_action :set_event_teammate_invitation
  before_action :require_pending
  before_action :require_user, only: :accept
  rescue_from ActiveRecord::RecordNotFound, :with => :incorrect_token

  decorates_assigned :event_teammate_invitation

  def accept
    @event_teammate_invitation.accept
    @event_teammate_invitation.create_event_teammate(current_user)

    redirect_to root_url,
      flash: { info: 'You successfully accepted the invitation' }
  end

  def refuse
    @event_teammate_invitation.refuse
    redirect_to root_url,
      flash: { danger: 'You successfully declined the invitation' }
  end

  private

  def set_event_teammate_invitation
    @event_teammate_invitation = EventTeammateInvitation.find_by!(slug: params[:slug],
                                                             token: params[:token])
  end

  def require_pending
    redirect_to root_url unless @event_teammate_invitation.pending?
  end

  protected
  def incorrect_token
    render :template => 'errors/incorrect_token', :status => :not_found
  end
end
