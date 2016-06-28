class Staff::EventsController < Staff::ApplicationController

  def edit
  end

  def show
    event_teammates = @event.event_teammates.includes(:user).recent
    rating_counts = @event.ratings.group(:user_id).count

    render locals: {
             event: @event.decorate,
             rating_counts: rating_counts,
             event_teammates: event_teammates
           }
  end

  #Edit Speaker Notification Emails
  def speaker_emails
  end

  #Edit Event Guidelines
  def guidelines
  end

  def update_custom_fields
    if @event.update_attributes(event_params)
      flash[:info] = 'Your event custom fields were updated.'
      redirect_to event_staff_url(@event)
    else
      flash[:danger] = flash[:danger] = 'There was a problem saving your event; please review the form for issues and try again.'
      render :edit_custom_fields
    end
  end

  def update
    if @event.update_attributes(event_params)
      flash[:info] = 'Your event was saved.'
      redirect_to event_staff_url(@event)
    else
      flash[:danger] = 'There was a problem saving your event; please review the form for issues and try again.'
      render :edit
    end
  end
end
