class Staff::EventsController < Staff::ApplicationController
  before_action :enable_staff_event_subnav

  def edit
    authorize @event, :edit?
  end

  def show
    render locals: { event: @event.decorate }
  end

  def info
  end

  def update_status
    authorize_update
    if @event.update(params.require(:event).permit(:state))
      redirect_to event_staff_info_path(@event), notice: "Event status was successfully updated."
    else
      flash[:danger] = "There was a problem updating the event status. Please try again."
      flash[:danger] += @event.errors.messages.values.flatten.map do |m|
        " <br>#{m}"
      end.join if @event.errors.present?
      @event.reload
      render :info
    end
  end

  def configuration
  end

  def reviewer_tags
    render partial: 'reviewer_tags_form'
  end

  def update_reviewer_tags
    authorize_update
    @event.update(params.require(:event).permit(:valid_review_tags))
    render partial: 'reviewer_tags', locals: {event: @event}
  end

  def proposal_tags
    render partial: 'proposal_tags_form'
  end

  def update_proposal_tags
    authorize_update
    @event.update(params.require(:event).permit(:valid_proposal_tags))
    render partial: 'proposal_tags', locals: {event: @event}
  end

  def update
    authorize_update
    if @event.update(event_params)
      if session[:target]
        redirect_to session[:target]
        session[:target].clear
      else
        redirect_to event_staff_info_path(@event)
      end
    else
      flash[:danger] = "There was a problem saving your event; please review the form for issues and try again."
      render :edit
    end
  end

  def open_cfp
    authorize_update
    if @event.update(state: Event::STATUSES[:open])
      flash[:info] = "Your CFP was successfully opened."
    else
      flash['danger alert-confirm'] = "There was a problem opening your CFP: #{@event.errors.full_messages.to_sentence}"
    end
    redirect_to event_staff_path(@event), status: :see_other
  end

  private

  def event_params
    params.require(:event).permit(
        :name, :contact_email, :slug, :url, :valid_proposal_tags,
        :valid_review_tags, :custom_fields_string, :state, :guidelines,
        :closes_at, :speaker_notification_emails, :accept, :reject,
        :waitlist, :opens_at, :start_date, :end_date)
  end

  def authorize_update
    authorize @event, :update?
  end
end
