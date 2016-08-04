class TeammatesController < ApplicationController
  before_action :require_invitation
  before_action :require_pending
  rescue_from ActiveRecord::RecordNotFound, :with => :incorrect_token

  def accept
    if !current_user
      session[:pending_invite] = accept_teammate_url(@teammate_invitation.token)
      flash[:info] = "Team invite to #{current_event.name} accepted!"
    else
      if already_teammate?
        flash[:danger] = "You are already a teammate for #{current_event.name}"
        redirect_to event_staff_teammates_path(current_event)
      else
        @teammate_invitation.accept(current_user)
        flash[:info] = "Team invite to #{current_event.name} accepted!"
        if current_user.complete?
          session.delete :pending_invite
          flash[:info] = "Congrats! You are now an official team member of #{current_event.name}!"
          redirect_to event_staff_path(current_event)
        else
          redirect_to edit_profile_path
        end
      end
    end
  end

  def decline
    @teammate_invitation.decline

    redirect_to root_url,
      flash: { danger: "You declined the invitation to #{current_event.name}." }
  end

  private

  def require_invitation
    @teammate_invitation = Teammate.find_by!(token: params[:token])
    set_current_event(@teammate_invitation.event_id)
  end

  def require_pending
    redirect_to root_url unless @teammate_invitation.pending?
  end

  def already_teammate?
    if current_event && current_user
      Teammate.exists?(event_id: current_event.id, id: current_user.id)
    end
  end

  protected

  def incorrect_token
    render :template => "errors/incorrect_token", :status => :not_found
  end

end
