class Organizer::EventsController < Organizer::ApplicationController

  def edit
    @partial = 'admin/events/form'
    if params[:form]
      @partial = "admin/events/#{params[:form]}"
    end
  end

  def show
    participants = @event.participants.includes(:person).recent
    rating_counts = @event.ratings.group(:person_id).count

    render locals: {
      event: @event.decorate,
      rating_counts: rating_counts,
      participants: participants
    }
  end

  def update
    if @event.update_attributes(event_params)
      flash[:info] = 'Your event was saved.'
      redirect_to organizer_event_path(@event)
    else
      flash[:danger] = 'There was a problem saving your event; please review the form for issues and try again.'
      render :edit
    end
  end

end
