class Staff::EventsController < Staff::ApplicationController
  before_action :enable_staff_event_subnav

  helper_method :sticky_template_test_email

  def edit
    authorize @event, :edit?
  end

  def show
    render locals: { event: @event.decorate }
  end

  #Edit Speaker Notification Emails
  def speaker_emails
    @event.initialize_speaker_emails
  end

  def update_speaker_emails
    authorize_update
    if @event.update(params.require(:event).permit(:accept, :reject, :waitlist))
      redirect_to event_staff_speaker_email_notifications_path
    else
      flash[:danger] = "There was a problem saving your email templates. #{@event.errors.full_messages.to_sentence}"
      render :speaker_emails
    end
  end

  def remove_speaker_email_template
    authorize_update
    if @event.remove_speaker_email_template(params[:type].to_sym)
      redirect_to event_staff_speaker_email_notifications_path
    else
      flash[:danger] = "There was a problem saving your email templates. #{@event.errors.full_messages.to_sentence}"
      render :speaker_emails
    end
  end

  def guidelines
  end

  def update_guidelines
    authorize_update
    if @event.update(params.require(:event).permit(:guidelines))
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
      flash[:danger] += @event.errors.messages.values.flatten.map do |m|
        " <br>#{m}"
      end.join if @event.errors.present?
      @event.reload
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
    if @event.update_attributes(state: Event::STATUSES[:open])
      flash[:info] = "Your CFP was successfully opened."
    else
      flash['danger alert-confirm'] = "There was a problem opening your CFP: #{@event.errors.full_messages.to_sentence}"
    end
    redirect_to event_staff_path(@event)
  end

  def test_speaker_template
    authorize_update

    self.sticky_template_test_email = template_test_params[:email]
    send_to = sticky_template_test_email
    @type_key = template_test_params[:type_key]
    template_display_name = SpeakerEmailTemplate::DISPLAY_TYPES[@type_key]

    Staff::ProposalMailer.send_test_email(send_to, @type_key, current_event).deliver_now

    flash.now[:info] = "'#{template_display_name}' test email successfully sent to #{send_to}."
  end

  private

  def event_params
    params.require(:event).permit(
        :name, :contact_email, :slug, :url, :valid_proposal_tags,
        :valid_review_tags, :custom_fields_string, :state, :guidelines,
        :closes_at, :speaker_notification_emails, :accept, :reject,
        :waitlist, :opens_at, :start_date, :end_date)
  end

  def template_test_params
    @template_test_params ||= params.require(:speaker_email_template).permit(:type_key, :email)
  end

  def sticky_template_test_email
    session["event/#{@event.id}/template_test_email"] if @event
  end

  def sticky_template_test_email=(email)
    session["event/#{@event.id}/template_test_email"] = email if @event
  end

  def authorize_update
    authorize @event, :update?
  end
end
