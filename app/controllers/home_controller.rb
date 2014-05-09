class HomeController < ApplicationController

  # Go to:
  # - the currently live event guidelines page, or
  # - /events if no current event
  def show
    @event = Event.live.first
    if @event
      redirect_to event_path(@event.slug)
    else
      redirect_to events_path
    end
  end

end