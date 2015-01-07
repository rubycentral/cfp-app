class Organizer::SpeakersController < Organizer::ApplicationController
  decorates_assigned :speaker

  def index
    render locals: {
      proposals: @event.proposals.includes(speakers: :person).decorate
    }
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
      redirect_to :back
    end
  end

  def emails
    emails = Proposal.where(id: params[:proposal_ids]).emails
    respond_to do |format|
      format.json { render json: {emails: emails} }
    end
  end

  private

  def speaker_params
    params.require(:speaker).permit(:bio)
  end
end
