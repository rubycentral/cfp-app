class Organizer::SpeakersController < Organizer::ApplicationController
  decorates_assigned :speaker

  def index
    render locals: {
             proposals: @event.proposals.includes(speakers: :person).decorate
           }
  end

  def new
    @speaker = Speaker.new
  end

  def create
    altered_params = proposal_params.merge!("state" => "accepted", "confirmed_at" => DateTime.now)
    @proposal = @event.proposals.new(altered_params)
    if @proposal.save
      flash[:success] = 'Proposal Added'
      redirect_to organizer_event_program_path(@event)
    else
      flash.now[:danger] = 'There was a problem saving your speaker; please review the form for issues and try again.'
      render :new
    end
  end

  def show
    @speaker = Speaker.find(params[:id])
  end

  def edit
    @speaker = Speaker.find(params[:id])
  end

  def update
    @speaker = Speaker.find(params[:id])
    if @speaker.update(speaker_params)
      redirect_to organizer_event_speaker_path(@event, @speaker)
    else
      render :edit
    end
  end

  def destroy
    @speaker = Speaker.find_by!(id: params[:id])

    @proposal = speaker.proposal
    speaker.destroy

    flash[:info] = "You've deleted the speaker for this proposal"
    redirect_to organizer_event_speaker_path(@event, @speaker)
  end

  def emails
    emails = Proposal.where(id: params[:proposal_ids]).emails
    respond_to do |format|
      format.json { render json: {emails: emails} }
    end
  end

  private

  def speaker_params
    params.require(:speaker).permit(:bio, :name)
  end
end
