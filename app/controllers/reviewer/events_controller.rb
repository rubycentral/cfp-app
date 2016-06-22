class Reviewer::EventsController < Reviewer::ApplicationController
  skip_before_filter :require_proposal

  def show
    event_teammate = EventTeammate.find_by(user_id: current_user)
    rating_counts = @event.ratings.group(:user_id).count

    render locals: {
             event: @event.decorate,
             rating_counts: rating_counts,
             event_teammate: event_teammate
           }
  end

end
