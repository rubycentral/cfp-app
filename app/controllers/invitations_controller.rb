class InvitationsController < ApplicationController
  before_filter :require_user, except: :show
  before_filter :require_invitation, except: :create
  before_filter :require_proposal, only: :create
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_not_found

  def create
    @invitation = @proposal.invitations.find_or_initialize_by(email: params[:email])

    if @invitation.save
      InvitationMailer.speaker(@invitation, current_user).deliver
      flash[:info] = "An invitation has been sent to #{params[:email]}."
    elsif !@invitation.valid?
      flash[:danger] = "Please enter a valid email and try again."
    else
      flash[:danger] = "We could not invite #{params[:email]} as a speaker; please try again later."
    end

    redirect_to :back
  end

  def destroy
    @invitation.destroy
    flash[:info] = "You have removed that invitation."
    redirect_to :back
  end

  def show
    render locals: {
      proposal: @invitation.proposal.decorate,
      invitation: @invitation.decorate
    }
  end

  def resend
    InvitationMailer.speaker(@invitation, current_user).deliver
    flash[:info] = "You have resent an invitation to #{@invitation.email}."
    redirect_to :back
  end

  def update
    if params[:refuse]
      @invitation.refuse
      flash[:info] = "You have refused this invitation."
      redirect_to :back
    else
      @invitation.accept
      flash[:info] = "You have accepted this invitation."
      @invitation.proposal.speakers.create(person: current_user)
      redirect_to edit_proposal_path(slug: @invitation.proposal.event.slug,
                                     uuid: @invitation.proposal)
    end
  end

  private

  def require_proposal
    @proposal = Proposal.find_by!(uuid: params[:proposal_uuid])
  end

  def require_invitation
    @invitation = Invitation.find_by!(slug: params[:invitation_slug] || session[:invitation_slug])
  end

  protected
  def rescue_not_found
    render :template => 'errors/incorrect_token', :status => :not_found
  end
end
