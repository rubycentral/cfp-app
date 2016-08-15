class TeammatesController < ApplicationController
  before_action :require_pending_invitation, only: [:accept, :decline]
  before_action :set_session_invite, only: [:accept]
  before_action :require_user_for_accept, only: [:accept]
  before_action :require_non_teammate, only: [:accept]

  def accept
    if @teammate_invitation.accept(current_user)
      clear_session_invite

      flash[:info] = "Congrats! You are now an official team member of #{current_event.name}! Before continuing, please take a moment to make sure your profile is complete."
      session[:target] = event_staff_path(current_event)
      redirect_to edit_profile_path

    else
      flash[:danger] = "A problem occurred while accepting your invitation."
      Rails.logger.error(@teammate_invitation.errors.full_messages.join(', '))
      redirect_to root_url
    end
  end

  def decline
    @teammate_invitation.decline

    redirect_to root_url,
      flash: { danger: "You declined the invitation to #{current_event.name}." }
  end

  private

  def require_pending_invitation
    @teammate_invitation = Teammate.pending.find_by(token: params[:token])
    if @teammate_invitation
      set_current_event(@teammate_invitation.event_id)
    else
      render :template => "errors/incorrect_token", :status => :not_found
    end
  end

  def set_session_invite
    session[:pending_invite_accept_url] = accept_teammate_url(@teammate_invitation.token)
    session[:pending_invite_email] = @teammate_invitation.email
  end

  def require_user_for_accept
    unless current_user
      flash[:info] = "To accept your invitation, you must log in or create an account."
      redirect_to new_user_session_url
    end
  end

  def require_non_teammate
    if current_user.staff_for?(current_event)
      flash[:danger] = "You are already a team member of #{current_event.name}"
      redirect_to event_staff_teammates_path(current_event)
    end
  end

  def clear_session_invite
    session.delete :pending_invite_accept_url
    session.delete :pending_invite_email
  end

end
