class Organizer::ParticipantsController < Organizer::ApplicationController
  respond_to :html, :json

  def create
    person = Person.where(email: params[:email]).first
    participant = @event.participants.build(participant_params.merge(person: person))

    if participant.save
      flash[:info] = 'Your participant was added.'
    else
      flash[:danger] = "There was a problem saving your participant;"
      if participant.errors[:person]
        flash[:danger] += " no person could be found for email '#{params[:email]}'."
      else
        flash[:danger] += ' please try again.'
      end
    end
    redirect_to organizer_event_path(@event)
  end

  def update
    participant = Participant.find(params[:id])
    participant.update(participant_params)

    flash[:info] = "You have successfully changed the role for your participant."
    redirect_to organizer_event_path(@event)
  end

  def destroy
    @event.participants.find(params[:id]).destroy

    flash[:info] = "Your participant has been deleted."
    redirect_to organizer_event_path(@event)
  end

  def emails
    emails = Person.where("email like ?",
                          "%#{params[:term]}%").order(:email).pluck(:email)
    respond_with emails.to_json, format: :json
  end

  private

  def participant_params
    params.require(:participant).permit(:role)
  end
end
