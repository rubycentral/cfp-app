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

  end

  def emails
    emails = Proposal.where(id: params[:proposal_ids]).emails
    respond_to do |format|
      format.json { render json: { emails: emails } }
    end
  end
end
