class ProposalsController < ApplicationController
  before_filter :require_event, except: :index
  before_filter :require_user
  before_filter :require_proposal, except: [ :index, :create, :new, :parse_edit_field ]
  before_filter :require_speaker, only: [:show, :edit, :update]
  before_filter :require_waitlisted_or_accepted_state, only: [:confirm]

  decorates_assigned :proposal

  def index
    proposals = current_user.proposals.decorate.to_a.group_by(&:event)

    render locals: {
      proposals: proposals,
      invitations: current_user.invitations.decorate
    }
  end

  def new
    @proposal = Proposal.new(event: @event)
    @proposal.speakers.build(user: current_user)
  end

  def confirm

  end

  def set_confirmed
    @proposal.update(confirmed_at: DateTime.now,
                     confirmation_notes: params[:confirmation_notes])
    redirect_to confirm_event_proposal_url(slug: @proposal.event.slug, uuid: @proposal),
      flash: { success: 'Thank you for confirming your participation' }
  end

  def withdraw
    @proposal.withdraw unless @proposal.confirmed?
    flash[:info] = "Your withdrawal request has been submitted."
    redirect_to event_event_proposals_url(slug: @proposal.event.slug, uuid: @proposal)
  end

  def destroy
    @proposal.destroy
    flash[:info] = "Your proposal has been deleted."
    redirect_to event_proposals_url
  end

  def create
    @proposal = @event.proposals.new(proposal_params)

    if @proposal.save
      current_user.update_bio
      flash[:info] = setup_flash_message
      redirect_to event_event_proposals_url(slug: @event.slug, uuid: @proposal)
    else
      flash[:danger] = 'There was a problem saving your proposal; please review the form for issues and try again.'
      render :new
    end
  end

  def show
    render locals: {
      invitations: @proposal.invitations.not_accepted.decorate
    }
  end

  def edit
  end

  def update
    if params[:confirm]
      @proposal.update(confirmed_at: DateTime.now)
      redirect_to event_event_proposals_url(slug: @event.slug, uuid: @proposal), flash: { success: 'Thank you for confirming your participation' }
    elsif @proposal.update_and_send_notifications(proposal_params)
      redirect_to event_proposal_url(event_slug: @event.slug, uuid: @proposal)
    else
      flash[:danger] = 'There was a problem saving your proposal; please review the form for issues and try again.'
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

  def proposal_params
    params.require(:proposal).permit(:title, {tags: []}, :session_type_id, :track_id, :abstract, :details, :pitch, custom_fields: @event.custom_fields,
                                     comments_attributes: [:body, :proposal_id, :user_id],
                                     speakers_attributes: [:bio, :user_id, :id])
  end

  def require_speaker
    unless current_user.proposal_ids.include?(@proposal.id)
      redirect_to root_path
      flash[:danger] = 'You are not a listed speaker on the proposal you are trying to access.'
    end
  end

  def setup_flash_message
    message = "Thank you for submitting a proposal."

    if @event.closes_at
      message +=
        " Expect a response after the CFP closes on #{@event.closes_at.to_s(:long)}."
    end
  end

  def require_waitlisted_or_accepted_state
    unless @proposal.waitlisted? || @proposal.accepted?
      redirect_to event_url(@event.slug)
    end
  end
end
