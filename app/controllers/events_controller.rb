class EventsController < ApplicationController
  before_filter :require_event, only: [:show]

  def index
    render locals: {
      events: Event.recent.decorate
    }
  end

  def show
  end
end
