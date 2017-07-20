class Organizer::ProposalsController < Organizer::ApplicationController
  before_filter :require_proposal, except: [:index, :new, :create, :edit_all]

  decorates_assigned :proposal, with: Organizer::ProposalDecorator

  def finalize
    @proposal.finalize
    send_state_mail(@proposal.state)
    redirect_to organizer_event_proposal_url(@proposal.event, @proposal)
  end

  def update_state
    @proposal.update_state(params[:new_state])

    respond_to do |format|
      format.html { redirect_to organizer_event_proposals_path(@proposal.event) }
      format.js
    end
  end

  def index
    proposals = @event.proposals.includes(:event, :review_taggings, :proposal_taggings, :ratings, {speakers: :person}).load

    session[:prev_page] = {name: 'Proposals', path: organizer_event_proposals_path}

    taggings_count = Tagging.count_by_tag(@event)

    proposals = Organizer::ProposalsDecorator.decorate(proposals)
    respond_to do |format|
      format.html { render locals: {event: @event, proposals: proposals, taggings_count: taggings_count} }
      format.csv { render text: proposals.to_csv }
    end
  end

  def show
    set_title(@proposal.title)
    other_proposals = []
    @proposal.speakers.each do |speaker|
      speaker.proposals.each do |p|
        if p.id != @proposal.id && p.event_id == @event.id
          other_proposals << p
        end
      end
    end

    current_user.notifications.mark_as_read_for_proposal(reviewer_event_proposal_url(@event, @proposal))
    render locals: {
             speakers: @proposal.speakers.decorate,
             other_proposals: Organizer::ProposalsDecorator.decorate(other_proposals),
             rating: current_user.rating_for(@proposal)
           }
  end

  def edit
  end


  def update
    if @proposal.update_without_touching_updated_by_speaker_at(proposal_params)
      flash[:info] = 'Proposal Updated'
      redirect_to organizer_event_proposals_url(slug: @event.slug)
    else
      flash[:danger] = 'There was a problem saving your proposal; please review the form for issues and try again.'
      render :edit
    end
  end

  def destroy
    @proposal.destroy
    flash[:info] = "Your proposal has been deleted."
    redirect_to organizer_event_proposals_url(@event)
  end

  def new
    @proposal = @event.proposals.new
    @speaker = @proposal.speakers.build
    @person = @speaker.build_person
  end

  def create
    altered_params = proposal_params.merge!("state" => "accepted", "confirmed_at" => DateTime.now)
    @proposal = @event.proposals.new(altered_params)
    if @proposal.save
      flash[:success] = 'Proposal Added'
      redirect_to organizer_event_program_url(@event)
    else
      flash.now[:danger] = 'There was a problem saving your proposal; please review the form for issues and try again.'
      render :new
    end
  end

  private

  def proposal_params
    # add updating_person to params so Proposal does not update last_change attribute when updating_person is organizer_for_event?
    params.require(:proposal).permit(:title, {review_tags: []}, :abstract, :details, :pitch, :slides_url, :video_url, custom_fields: @event.custom_fields,
                                     comments_attributes: [:body, :proposal_id, :person_id],
                                     speakers_attributes: [:bio, :person_id, :id,
                                                           person_attributes: [:id, :name, :email, :bio]])
  end

  def send_state_mail(state)
    case state
      when Proposal::State::ACCEPTED
        Organizer::ProposalMailer.accept_email(@event, @proposal).deliver_now
      when Proposal::State::REJECTED
        Organizer::ProposalMailer.reject_email(@event, @proposal).deliver_now
      when Proposal::State::WAITLISTED
        Organizer::ProposalMailer.waitlist_email(@event, @proposal).deliver_now
    end
  end
end
