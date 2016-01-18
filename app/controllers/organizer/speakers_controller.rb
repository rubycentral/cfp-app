class Organizer::SpeakersController < Organizer::ApplicationController
  decorates_assigned :speaker
  before_filter :set_proposal, only: [:new, :create, :destroy]

  def index
    render locals: {
             proposals: @event.proposals.includes(speakers: :person).decorate
           }
  end

  def new
    @speaker = Speaker.new
    @person = @speaker.build_person
    @proposal = Proposal.find_by(uuid: params[:proposal_uuid])
  end

  def create
    s_params = speaker_params
    person = Person.find_by(email: s_params.delete(:email))
    if person
      if person.speakers.create(s_params.merge(proposal: @proposal))
        flash[:success] = "Speaker was added to this proposal"
      else
        flash[:danger] = "There was a problem saving this speaker"
      end
    else
      flash[:danger] = "Could not find a person with this email address"
    end
    redirect_to organizer_event_proposal_url(event, @proposal)
  end

  #if user input (params), exist

  def show
    @speaker = Speaker.find(params[:id])
  end

  def edit
    @speaker = Speaker.find(params[:id])
  end

  def update
    @speaker = Speaker.find(params[:id])
    if @speaker.update(speaker_params)
      redirect_to organizer_event_speaker_url(@event, @speaker)
    else
      render :edit
    end
  end

  def destroy
    @speaker = Speaker.find_by!(id: params[:id])
    proposal = speaker.proposal
    @speaker.destroy

    flash[:info] = "You've deleted the speaker for this proposal"
    redirect_to organizer_event_proposal_url(uuid: proposal)
  end

  def emails
    emails = Proposal.where(id: params[:proposal_ids]).emails
    respond_to do |format|
      format.json { render json: {emails: emails} }
    end
  end

  private

  def speaker_params
    params.require(:speaker).permit(:bio, :email,
                              person_attributes: [:id, :name, :email, :bio])
  end

  def set_proposal
    @proposal = Proposal.find_by(uuid: params[:proposal_uuid])
  end
end
