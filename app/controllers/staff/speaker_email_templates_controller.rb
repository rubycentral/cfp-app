class Staff::SpeakerEmailTemplatesController < Staff::ApplicationController
  before_action :enable_staff_event_subnav
  before_action :set_type_key, only: [:show, :edit, :update, :destroy, :test]

  helper_method :sticky_template_test_email

  def index
    @event.initialize_speaker_emails
  end

  def show
  end

  def edit
  end

  def update
    authorize @event, :update?
    if @event.update(params.require(:event).permit(@type_key))
      redirect_to event_staff_speaker_email_template_path(@event, @type_key)
    else
      flash[:danger] = "There was a problem saving your email template. #{@event.errors.full_messages.to_sentence}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event, :update?
    if @event.remove_speaker_email_template(@type_key)
      redirect_to event_staff_speaker_email_template_path(@event, @type_key)
    else
      flash[:danger] = "There was a problem removing the template. #{@event.errors.full_messages.to_sentence}"
      redirect_to event_staff_speaker_email_template_path(@event, @type_key)
    end
  end

  def test
    authorize @event, :update?

    self.sticky_template_test_email = params.require(:speaker_email_template).permit(:email)[:email]
    send_to = sticky_template_test_email
    template_display_name = SpeakerEmailTemplate::DISPLAY_TYPES[@type_key]

    Staff::ProposalMailer.send_test_email(send_to, @type_key, current_event).deliver_now

    flash[:info] = "'#{template_display_name}' test email successfully sent to #{send_to}."
    redirect_to event_staff_speaker_email_templates_path(@event)
  end

  private

  def set_type_key
    @type_key = params[:id].to_sym
    unless SpeakerEmailTemplate::TYPES.include?(@type_key)
      raise ActiveRecord::RecordNotFound
    end
    @type_text = SpeakerEmailTemplate::DISPLAY_TYPES[@type_key]
    @text = @event.speaker_notification_emails[@type_key]
  end

  def sticky_template_test_email
    session["event/#{@event.id}/template_test_email"] if @event
  end

  def sticky_template_test_email=(email)
    session["event/#{@event.id}/template_test_email"] = email if @event
  end
end
