class ProposalsController < ApplicationController
  before_action :require_event, except: :index
  before_action :require_user
  before_action :require_proposal, except: [ :index, :create, :new, :parse_edit_field ]
  before_action :require_invite_or_speaker, only: [:show]
  before_action :require_speaker, except: [ :index, :create, :new, :parse_edit_field ]

  decorates_assigned :proposal

  def index
    proposals = current_user.proposals.decorate.group_by {|p| p.event}
    invitations = current_user.pending_invitations.decorate.group_by {|inv| inv.proposal.event}
    events = (proposals.keys | invitations.keys).uniq

    render locals: {
        events: events,
        proposals: proposals,
        invitations: invitations
    }
  end

  def finalized_notification
    @proposal = proposal # because drapper won't set the instance variable

    email_template = case @proposal.state
      when Proposal::State::ACCEPTED
        'accept_email'
      when Proposal::State::REJECTED
        'reject_email'
      when Proposal::State::WAITLISTED
        'waitlist_email'
    end

    markdown_string = render_to_string "staff/proposal_mailer/#{email_template}", layout: false, formats: :md

    @body = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(markdown_string)
  end

  def new
    if @event.closed?
      redirect_to event_path (@event)
      flash[:danger] = "The CFP is closed for proposal submissions."
      return
    end
    @proposal = @event.proposals.new
    @proposal.speakers.build(user: current_user, houston_or_providence: Speaker::HOUSTON_OR_PROVIDENCE.first)
    flash.now[:warning] = incomplete_profile_msg unless current_user.complete?
  end

  def update_notes
    if @proposal.update(confirmation_notes: notes_params[:confirmation_notes])
      flash[:success] = "Confirmation notes successfully updated."
      redirect_to event_proposal_path(slug: @proposal.event.slug, uuid: @proposal)
    else
      flash[:danger] = "There was a problem updating confirmation notes."
      render :show
    end
  end

  def confirm
    @proposal.confirm
    flash[:success] = "You have confirmed your participation in #{@proposal.event.name}."
    redirect_to event_proposal_path(slug: @proposal.event.slug, uuid: @proposal)
  end

  def withdraw
    @proposal.withdraw unless @proposal.confirmed?
    flash[:info] = "As requested, your talk has been removed for consideration."
    redirect_to event_proposal_url(slug: @proposal.event.slug, uuid: @proposal)
  end

  def decline
    @proposal.decline
    flash[:info] = "As requested, your talk has been removed for consideration."
    redirect_to event_proposal_url(slug: @proposal.event.slug, uuid: @proposal)
  end

  def destroy
    @proposal.destroy
    flash[:info] = "Your proposal has been deleted."
    redirect_to event_proposals_url
  end

  def create
    if @event.closed? && @event.closes_at < 1.hour.ago
      redirect_to event_path (@event)
      flash[:danger] = "The CFP is closed for proposal submissions."
      return
    end
    @proposal = @event.proposals.new(proposal_params)
    speaker = @proposal.speakers[0]
    speaker.user_id = current_user.id
    speaker.event_id = @event.id

    if @proposal.save
      # NOTE: more houstong or providence hackery
      hack_location_taggings
      current_user.update_bio
      flash[:confirm] = setup_flash_message
      redirect_to event_proposal_url(event_slug: @event.slug, uuid: @proposal)
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
      @proposal.update(confirmed_at: DateTime.current)
      redirect_to event_event_proposals_url(slug: @event.slug, uuid: @proposal), flash: { success: "Thank you for confirming your participation" }
    elsif @proposal.speaker_update_and_notify(proposal_params)
      # NOTE: more houstong or providence hackery
      hack_location_taggings
      redirect_to event_proposal_url(event_slug: @event.slug, uuid: @proposal)
    else
      flash[:danger] = "There was a problem saving your proposal."
      render :edit
    end
  end

  include ApplicationHelper
  def parse_edit_field
    respond_to do |format|
      format.js do
        render locals: {
          field_id: params[:id],
          text: markdown(params[:text])
        }
      end
    end
  end

  private

  def hack_location_taggings
    speaker = @proposal.speakers.first
    speaker.proposals.where(event: @proposal.event).each do |p|
      p.taggings.where(internal: true, tag: %w(providence houston)).destroy_all
      if speaker.houston_or_providence =~ /texas/i
        p.taggings.create(tag: "houston", internal: true)
      else
        p.taggings.create(tag: "providence", internal: true)
      end
    end
  end

  def proposal_params
    params.require(:proposal).permit(:title, {tags: []}, :session_format_id, :track_id, :abstract, :details, :pitch, custom_fields: @event.custom_fields,
                                     comments_attributes: [:body, :proposal_id, :user_id],
                                     speakers_attributes: [:bio, :id, :age_range, :pronouns, :ethnicity, :first_time_speaker, :houston_or_providence])
  end

  def notes_params
    params.require(:proposal).permit(:confirmation_notes)
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
      message << "  Expect a response regarding acceptance after the CFP closes on #{@event.closes_at.to_s(:long)}."
    end

    message << "</p>"
  end

  def require_waitlisted_or_accepted_state
    unless @proposal.waitlisted? || @proposal.accepted?
      redirect_to event_url(@event.slug)
    end
  end

  def incomplete_profile_msg
    if profile_errors = current_user.profile_errors
      msg = "Before submitting a proposal your profile needs completing. Please correct the following: "
      msg << profile_errors.full_messages.to_sentence
      msg << ". Visit #{view_context.link_to('My Profile', edit_profile_path)} to update."
      msg.html_safe
    end
  end
end
