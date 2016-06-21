class HomeController < ApplicationController

  # Go to:
  # - the currently live event guidelines page, or
  # - /events if no current event
  def show
    live_events = Event.live.all
    if live_events.count == 1
      redirect_to event_url(live_events.first.slug)
    else
      redirect_to events_url
    end
  end

end
