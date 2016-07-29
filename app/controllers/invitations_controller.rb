class InvitationsController < ApplicationController
  before_filter :require_user, except: [:show, :update]
  before_filter :require_invitation, except: :create
  before_filter :require_proposal, only: :create
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_not_found

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

    redirect_to :back
  end

  def destroy
    @invitation.destroy
    flash[:info] = "You have removed the invitation for #{@invitation.email}."
    redirect_to :back
  end

  def show
    @proposal = @invitation.proposal.decorate
    @invitation = @invitation.decorate
    @event = @invitation.proposal.event.decorate

    if current_user && session[:pending_invite]
      accept_invite
      session.delete :pending_invite
    end
  end

  def resend
    SpeakerInvitationMailer.create(@invitation, current_user).deliver_now
    flash[:info] = "You have resent an invitation to #{@invitation.email}."
    redirect_to :back
  end

  def update
    if params[:decline]
      @invitation.decline
      flash[:info] = "You have declined this invitation."
      redirect_to root_url
    else
      if current_user
        accept_invite
      else
        session[:pending_invite] = invitation_path(params[:invitation_slug])
        flash[:info] = "Thanks for joining us! Please sign in or create an account."
        redirect_to new_user_session_path
      end
    end
  end

  private

  def require_proposal
    @proposal = Proposal.find_by!(uuid: params[:proposal_uuid])
  end

  def require_invitation
    @invitation = Invitation.find_by!(slug: params[:invitation_slug] || session[:invitation_slug])
  end

  def accept_invite
    @invitation.accept
    flash[:info] = "You have accepted your invitation!"
    @invitation.proposal.speakers.create(user: current_user, event: @invitation.proposal.event)
    if current_user.complete?
      redirect_to event_proposal_path(event_slug: @invitation.proposal.event.slug,
                                      uuid: @invitation.proposal)
    else
      redirect_to edit_profile_path
    end
  end

  protected
  def rescue_not_found
    render :template => 'errors/incorrect_token', :status => :not_found
  end
end
