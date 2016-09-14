class Staff::ProposalsController < Staff::ApplicationController
  before_action :enable_staff_program_subnav
  before_action :set_proposal_counts, only: [:index, :show, :selection]

  before_action :require_proposal, only: [:show, :update_state, :update_track, :finalize]

  decorates_assigned :proposal, with: Staff::ProposalDecorator

  def index
    session[:prev_page] = {name: 'Proposals', path: event_staff_program_proposals_path}

    @proposals = @event.proposals
                     .includes(:event, :review_taggings, :proposal_taggings, :ratings,
                               {speakers: :user}).load
    @proposals = Staff::ProposalsDecorator.decorate(@proposals)
    @taggings_count = Tagging.count_by_tag(@event)
  end

  def show
    set_title(@proposal.title)
    current_user.notifications.mark_as_read_for_proposal(event_staff_proposal_url(@event, @proposal))

    @other_proposals = Staff::ProposalsDecorator.decorate(@proposal.other_speakers_proposals)
    @speakers = @proposal.speakers.decorate
    @rating = current_user.rating_for(@proposal)
  end

  def update_state
    authorize @proposal

    @proposal.update_state(params[:new_state])

    respond_to do |format|
      format.html { redirect_to event_staff_program_proposals_path(@proposal.event) }
      format.js
    end
  end

  def update_track
    authorize @proposal

    @proposal.update(track_id: params[:track_id])

    render partial: '/staff/proposals/inline_track_edit'
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
    authorize @proposal

    @proposal.finalize
    send_state_mail(@proposal.state)
    redirect_to event_staff_program_proposal_path(@proposal.event, @proposal)
  end

  private

  def send_state_mail(state)
    case state
      when Proposal::State::ACCEPTED
        Staff::ProposalMailer.accept_email(@event, @proposal).deliver_now
      when Proposal::State::REJECTED
        Staff::ProposalMailer.reject_email(@event, @proposal).deliver_now
      when Proposal::State::WAITLISTED
        Staff::ProposalMailer.waitlist_email(@event, @proposal).deliver_now
    end
  end
end
