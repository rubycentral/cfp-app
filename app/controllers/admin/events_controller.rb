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
      redirect_to organizer_event_url(@event)
    else
      flash[:danger] = 'There was a problem saving your event; please review the form for issues and try again.'
      render :new
    end
  end

  def destroy
    @event.destroy
    flash[:info] = "Your event has been deleted."
    redirect_to events_url
  end

  def archive
    @event = Event.find_by(id: params[:event_id])
    if @event
      @event.archive
      flash[:warning] = "#{@event.name} is now archived."
    else
      flash[:danger] = "Event not found. Unable to archive."
    end
    redirect_to admin_events_url
  end

  def unarchive
    @event = Event.find_by(id: params[:event_id])
    if @event
      @event.unarchive
      flash[:warning] = "#{@event.name} is now current."
    else
      flash[:danger] = "Event not found. Unable to unarchive."
    end
    redirect_to admin_events_url
  end

  def index
    @events = Event.order("archived").all
  end

end
