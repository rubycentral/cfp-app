class Admin::EventsController < Admin::ApplicationController
  before_filter :require_event, only: [:destroy]

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
			@event.participants.create(person: current_user, role: 'organizer')
      flash[:info] = 'Your event was saved.'
      redirect_to organizer_event_path(@event)
    else
      flash[:danger] = 'There was a problem saving your event; please review the form for issues and try again.'
      render :new
    end
  end

  def destroy
    @event.destroy
    flash[:info] = "Your event has been deleted."
    redirect_to events_path
  end

end
