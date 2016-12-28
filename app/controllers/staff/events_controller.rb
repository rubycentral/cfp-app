class Staff::EventsController < Staff::ApplicationController
  before_action :enable_staff_event_subnav

  def edit
    authorize @event, :edit?
  end

  def show
    render locals: { event: @event.decorate }
  end

  #Edit Speaker Notification Emails
  def speaker_emails
  end

  def update_speaker_emails
    authorize_update
    if @event.update(params.require(:event).permit(:accept, :reject, :waitlist))
      flash[:info] = "Your speaker email templates were updated."
      redirect_to event_staff_speaker_email_notifications_path
    else
      flash[:danger] = "There was a problem saving your email templates; please review the form for issues and try again."
      render :speaker_email_notifications
    end
  end

  def remove_speaker_email_template
    authorize_update
    if @event.remove_speaker_email_template(params[:type].to_sym)
      flash[:info] = "Your speaker email templates were updated."
      redirect_to event_staff_speaker_email_notifications_path
    else
      flash[:danger] = "There was a problem saving your email templates; please review the form for issues and try again."
      render :speaker_email_notifications
    end
  end

  def guidelines
  end

  def update_guidelines
    authorize_update
    if @event.update(params.require(:event).permit(:guidelines))
      flash[:info] = "Your guidelines were updated."
      redirect_to event_staff_guidelines_path
    else
      flash[:danger] = "There was a problem saving your guidelines; please review the form for issues and try again."
      render :guidelines
    end
  end

  def info
  end

  def update_status
    authorize_update
    if @event.update(params.require(:event).permit(:state))
      redirect_to event_staff_info_path(@event), notice: "Event status was successfully updated."
    else
      flash[:danger] = "There was a problem updating the event status. Please try again."
      render :info
    end
  end

  def configuration
  end

  def update_custom_fields
    authorize_update
    @event.update_attributes(event_params)
    respond_to do |format|
      format.js do
        render locals: { event: @event }
      end
    end
  end

  def update_reviewer_tags
    authorize_update
    @event.update(params.require(:event).permit(:valid_review_tags))
    respond_to do |format|
      format.js do
        render locals: { event: @event }
      end
    end
  end

  def update_proposal_tags
    authorize_update
    @event.update(params.require(:event).permit(:valid_proposal_tags))
    respond_to do |format|
      format.js do
        render locals: { event: @event }
      end
    end
  end

  def update
    authorize_update
    if @event.update_attributes(event_params)
      flash[:info] = "Your event was saved."
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
    if @event.open_cfp
      flash[:info] = "Your CFP was successfully opened."
    else
      flash[:danger] = "There was a problem opening your CFP: #{@event.errors.full_messages.to_sentence}"
    end
    redirect_to event_staff_path(@event)
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
