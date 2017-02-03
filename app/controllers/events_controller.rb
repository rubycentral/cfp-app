class EventsController < ApplicationController
  skip_before_action :current_event, only: [:index]
  before_action :require_event, only: [:show]

  def index
    render locals: {
      events: Event.not_draft.closes_up.decorate
    }
  end

  def show
  end
end
