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

  def guidelines
  end

  def update_guidelines
    if @event.update(params.require(:event).permit(:guidelines))
      flash[:info] = 'Your guidelines were updated.'
      redirect_to event_staff_guidelines_path
    else
      flash[:danger] = 'There was a problem saving your guidelines; please review the form for issues and try again.'
      render :guidelines
    end
  end

  def info
  end

  def update_status
    if @event.update_attributes(event_params)
      redirect_to event_staff_info_path(@event), notice: 'Event status was successfully updated.'
    else
      flash[:danger] = 'There was a problem updating the event status. Please try again.'
      render :info
    end
  end

  def update_custom_fields
    if @event.update_attributes(event_params)
      flash[:info] = 'Your event custom fields were updated.'
      redirect_to event_staff_path(@event)
    else
      flash[:danger] = 'There was a problem saving your event; please review the form for issues and try again.'
      render :edit_custom_fields
    end
  end

  def update
    if @event.update_attributes(event_params)
      flash[:info] = 'Your event was saved.'
      redirect_to event_staff_info_path(@event)
    else
      flash[:danger] = 'There was a problem saving your event; please review the form for issues and try again.'
      render :edit
    end
  end

  private

  def event_params
    params.require(:event).permit(
        :name, :contact_email, :slug, :url, :valid_proposal_tags,
        :valid_review_tags, :custom_fields_string, :state, :guidelines,
        :closes_at, :speaker_notification_emails, :accept, :reject,
        :waitlist, :opens_at, :start_date, :end_date)
  end
end
