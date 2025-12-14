class ProposalsController < ApplicationController
  before_action :require_event, except: :index
  before_action :require_user
  before_action :require_proposal, except: [ :index, :create, :new, :preview ]
  before_action :load_proposal_associations, only: :show
  before_action :require_invite_or_speaker, only: [:show]
  before_action :require_speaker, except: [ :index, :create, :new, :preview ]

  decorates_assigned :proposal

  def index
    proposals = current_user.proposals.
      select("proposals.*, (#{PublicComment.select('count(*)').where('proposal_id = proposals.id').to_sql}) as public_comments_count").
      includes(:event, {speakers: :user}, :session_format).order(event_id: :desc).decorate.group_by {|p| p.event}
    invitations = current_user.pending_invitations.decorate.group_by {|inv| inv.proposal.event}
    events = (proposals.keys | invitations.keys).uniq

    render locals: {
        events: events,
        proposals: proposals,
        invitations: invitations
    }
  end

  def new
    if @event.closed?
      redirect_to @event
      flash[:danger] = "The CFP is closed for proposal submissions."
      return
    end
    @proposal = @event.proposals.new
    @proposal.speakers.build(user: current_user)
    flash.now[:warning] = incomplete_profile_msg unless current_user.complete?
  end

  def update_notes
    if @proposal.update(confirmation_notes: notes_params[:confirmation_notes])
      flash[:success] = "Confirmation notes successfully updated."
      redirect_to [@proposal.event, @proposal]
    else
      flash[:danger] = "There was a problem updating confirmation notes."
      render :show
    end
  end

  def confirm
    @proposal.confirm
    flash[:success] = "You have confirmed your participation in #{@proposal.event.name}."
    redirect_to [@proposal.event, @proposal], status: :see_other
  end

  def withdraw
    @proposal.withdraw unless @proposal.confirmed?
    flash[:info] = "As requested, your talk has been removed for consideration."
    redirect_to [@proposal.event, @proposal], status: :see_other
  end

  def decline
    @proposal.decline
    flash[:info] = "As requested, your talk has been removed for consideration."
    redirect_to [@proposal.event, @proposal], status: :see_other
  end

  def destroy
    @proposal.destroy
    flash[:info] = "Your proposal has been deleted."
    redirect_to event_proposals_url(@event), status: :see_other
  end

  def create
    if @event.closed? && @event.closes_at < 1.hour.ago
      redirect_to @event
      flash[:danger] = "The CFP is closed for proposal submissions."
      return
    end
    @proposal = @event.proposals.new(proposal_params)
    speaker = @proposal.speakers[0]
    speaker.user_id = current_user.id
    speaker.event_id = @event.id

    if @proposal.save
      current_user.update_bio
      flash[:confirm] = setup_flash_message
      redirect_to [@event, @proposal]
    else
      flash[:danger] = "There was a problem saving your proposal."
      render :new
    end
  end

  def show
    session[:event_id] = event.id

    render locals: {
      invitations: @proposal.invitations.not_accepted.decorate,
      event: @proposal.event.decorate
    }
  end

  def edit
  end

  def update
    if params[:confirm]
      @proposal.update(confirmed_at: Time.current)
      redirect_to [@event, @proposal], flash: {success: 'Thank you for confirming your participation'}
    elsif @proposal.speaker_update_and_notify(proposal_params)
      redirect_to [@event, @proposal]
    else
      flash[:danger] = "There was a problem saving your proposal."
      render :edit
    end
  end

  def preview
    @proposal = @event.proposals.new(preview_params).decorate
    render partial: 'preview', locals: { proposal: @proposal }
  end

  private

  def proposal_params
    params.require(:proposal).permit(:title, {tags: []}, :session_format_id, :track_id, :abstract, :details, :pitch, custom_fields: @event.custom_fields,
                                     comments_attributes: [:body, :proposal_id, :user_id],
                                     speakers_attributes: [:bio, :id, :age_range, :pronouns, :ethnicity, :first_time_speaker])
  end

  def preview_params
    params.fetch(:proposal, {}).permit(:title, {tags: []}, :session_format_id, :track_id, :abstract, :details, :pitch, custom_fields: @event.custom_fields)
  end

  def notes_params
    params.require(:proposal).permit(:confirmation_notes)
  end

  def load_proposal_associations
    @proposal.speakers.load
    @proposal.public_comments.load
  end

  def require_invite_or_speaker
    unless @proposal.has_speaker?(current_user) || @proposal.has_invited?(current_user)
      redirect_to root_path
      flash[:danger] = "You are not an invited speaker for the proposal you are trying to access."
    end
  end

  def require_speaker
    unless @proposal.has_speaker?(current_user)
      redirect_to root_path
      flash[:danger] = "You are not a listed speaker for the proposal you are trying to access."
    end
  end

  def setup_flash_message
    message = "<h2 class='text-center'>Thank you!</h2>"
    message << "<p>Your proposal has been submitted and may be reviewed at any time while the CFP is open.  You are welcome to update your proposal or leave a comment at any time, just please be sure to preserve your anonymity."

    if @event.closes_at
      message << "  Expect a response regarding acceptance after the CFP closes on #{@event.closes_at.to_fs(:long)}."
    end

    message << "</p>"
  end

  def require_waitlisted_or_accepted_state
    unless @proposal.waitlisted? || @proposal.accepted?
      redirect_to @event
    end
  end

  def incomplete_profile_msg
    if (profile_errors = current_user.profile_errors)
      msg = "Before submitting a proposal your profile needs completing. Please correct the following: ".html_safe
      msg << profile_errors.full_messages.to_sentence
      msg << ". Visit " << view_context.link_to('My Profile', edit_profile_path) << " to update."
    end
  end
end
