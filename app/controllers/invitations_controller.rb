class InvitationsController < ApplicationController
  before_action :require_proposal, only: [:create, :destroy, :resend]
  before_action :require_speaker, only: [:create, :destroy, :resend]
  before_action :require_pending_invitation, only: [:show, :accept, :decline, :destroy, :resend]
  before_action :set_session_invite, only: [:accept]
  before_action :require_user_for_accept, only: [:accept]

  def show
    @proposal = @invitation.proposal.decorate
    @invitation = @invitation.decorate
    @event = @invitation.proposal.event.decorate
  end

  def accept
    if @invitation.accept(current_user)
      clear_session_invite

      flash[:info] = "You have accepted your invitation! Before continuing, please take a moment to make sure your profile is complete."
      session[:target] = event_proposal_path(event_slug: @invitation.proposal.event.slug,
                                            uuid: @invitation.proposal)
      redirect_to edit_profile_path

    else
      flash[:danger] = "A problem occurred while accepting your invitation."
      Rails.logger.error(@invitation.errors.full_messages.join(', '))
      redirect_to invitation_path(@invitation.slug)
    end
  end

  def decline
    @invitation.decline

    flash[:info] = "You have declined this invitation."
    redirect_to root_url
  end

  def create
    @invitation = @proposal.invitations.find_or_initialize_by(email: params[:speaker][:email])

    if @invitation.save
      SpeakerInvitationMailer.create(@invitation, current_user).deliver_now
      flash[:info] = "An invitation has been sent to #{params[:speaker][:email]}."
    elsif !@invitation.valid?
      flash[:danger] = "Please enter a valid email and try again."
    else
      flash[:danger] = "We could not invite #{params[:speaker][:email]} as a speaker; please try again later."
    end

    redirect_back fallback_location: event_proposal_path(@proposal.event, uuid: @proposal)
  end

  def destroy
    @invitation.destroy
    redirect_back fallback_location: event_proposal_path(@proposal.event, uuid: @proposal)
  end

  def resend
    SpeakerInvitationMailer.create(@invitation, current_user).deliver_now
    flash[:info] = "You have resent an invitation to #{@invitation.email}."
    redirect_back fallback_location: event_proposal_path(@proposal.event, uuid: @proposal)
  end

  private

  def require_proposal
    @proposal = Proposal.find_by(uuid: params[:proposal_uuid])
    unless @proposal
      render :template => 'errors/incorrect_token', :status => :not_found
    end
  end

  def require_speaker
    unless current_user && @proposal.has_speaker?(current_user)
      flash[:danger] = "You must be a speaker for this proposal in order to invite other speakers."
      redirect_to new_user_session_url
    end
  end

  def require_pending_invitation
    @invitation = Invitation.pending.find_by(slug: params[:invitation_slug])
    if @invitation
      set_current_event(@invitation.proposal.event_id)
    else
      render :template => 'errors/incorrect_token', :status => :not_found
    end
  end

  def set_session_invite
    session[:pending_invite_accept_url] = accept_invitation_path(@invitation.slug)
    session[:pending_invite_email] = @invitation.email
  end

  def require_user_for_accept
    unless current_user
      flash[:info] = "To accept your invitation, you must log in or create an account."
      redirect_to new_user_session_url
    end
  end

  def clear_session_invite
    session.delete :pending_invite_accept_url
    session.delete :pending_invite_email
  end
end
