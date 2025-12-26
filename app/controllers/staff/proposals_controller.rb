class Staff::ProposalsController < Staff::ApplicationController
  include ProgramSupport

  before_action :require_proposal, only: [:show, :update_state, :update, :finalize]
  before_action :enable_staff_selection_subnav
  skip_before_action :require_program_team, only: [:update]
  before_action :require_staff, only: [:update]

  decorates_assigned :proposal, with: Staff::ProposalDecorator

  def index
    session[:prev_page] = {name: 'Proposals', path: event_staff_program_proposals_path}

    @proposals = @event.proposals
                   .includes(:event, :review_taggings, :proposal_taggings, :ratings, :session_format, {speakers: :user}).load
    @proposals = Staff::ProposalsDecorator.decorate(@proposals)

    accepted_proposals = @event.proposals.accepted
    @accepted_not_confirmed_count = accepted_proposals.where(confirmed_at: nil).count
    @accepted_confirmed_count = accepted_proposals.where.not(confirmed_at: nil).count
  end

  def show
    set_title(@proposal.title)
    current_user.notifications.mark_as_read_for_proposal(event_staff_proposal_url(@event, @proposal))

    @other_proposals = Staff::ProposalsDecorator.decorate(@proposal.other_speakers_proposals)
    @speakers = @proposal.speakers.decorate
    @rating = current_user.rating_for(@proposal)
    @mention_names = current_event.mention_names
  end

  def update_state
    if @proposal.finalized?
      authorize @proposal, :finalize?
    else
      authorize @proposal, :update_state?
    end

    case params[:new_state]
    when 'soft_accepted'
      @proposal.soft_accept
    when 'soft_waitlisted'
      @proposal.soft_waitlist
    when 'soft_rejected'
      @proposal.soft_reject
    when 'submitted'
      @proposal.finalized? ? @proposal.hard_reset : @proposal.reset
    end

    respond_to do |format|
      format.html { redirect_to event_staff_program_proposals_path(@proposal.event), status: :see_other }
      format.turbo_stream
    end
  end

  def update
    authorize @proposal

    @proposal.update!(proposal_update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to event_staff_program_proposal_path(@event, @proposal), status: :see_other }
    end
  end

  def selection
    session[:prev_page] = {name: 'Selection', path: selection_event_staff_program_proposals_path}

    @proposals = @event.proposals.working_program
                 .includes(:event, :review_taggings, :ratings,
                           {speakers: :user}).load
    @proposals = Staff::ProposalsDecorator.decorate(@proposals)
    @taggings_count = Tagging.count_by_tag(@event)
  end

  def session_counts
    track = params[:track_id]
    self.sticky_selected_track = track
    render json: {
        all_accepted_proposals: current_event.stats.all_accepted_proposals(sticky_selected_track),
        all_waitlisted_proposals: current_event.stats.all_waitlisted_proposals(sticky_selected_track)
      }
  end

  def finalize
    authorize @proposal, :finalize?

    if @proposal.finalize
      FinalizationNotifier.notify(@proposal)
    else
      flash[:danger] = "There was a problem finalizing the proposal: #{@proposal.errors.full_messages.join(', ')}"
    end
    redirect_to event_staff_program_proposal_path(@proposal.event, @proposal), status: :see_other
  end

  def bulk_finalize
    authorize Proposal, :bulk_finalize?

    @remaining_by_state = Proposal.soft_states.group_by(&:state)
  end

  def finalize_by_state
    state = params[:proposals_state]
    remaining = Proposal.where(state: state)
    authorize remaining, :finalize?

    BulkFinalizeJob.perform_later(state)

    ActionCable.server.broadcast "notifications", {
      message: "#{state} queued for finalization"
    }
    head :no_content
  end

  private

  def proposal_update_params
    params.require(:proposal).permit(:track_id, :session_format_id)
  end
end
