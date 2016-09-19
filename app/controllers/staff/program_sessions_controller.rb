class Staff::ProgramSessionsController < Staff::ApplicationController
  before_action :enable_staff_program_subnav
  before_action :set_proposal_counts

  decorates_assigned :program_session, with: Staff::ProgramSessionDecorator
  decorates_assigned :sessions, with: Staff::ProgramSessionDecorator
  decorates_assigned :waitlisted_sessions, with: Staff::ProgramSessionDecorator

  def index
    @sessions = @event.program_sessions.active_or_inactive
    @waitlisted_sessions = @event.program_sessions.waitlisted

    session[:prev_page] = { name: 'Program', path: event_staff_program_sessions_path(@event) }
  end

  def show
    @program_session = @event.program_sessions.find(params[:id])
    @speakers = @program_session.speakers
  end

  def edit
    @program_session = @event.program_sessions.find(params[:id])
    authorize @program_session
  end

  def update
    @program_session = @event.program_sessions.find(params[:id])
    authorize @program_session
    if @program_session.update(program_session_params)
      flash[:success] = "#{@program_session.title} was successfully updated."
      redirect_to event_staff_program_session_path(@event, @program_session)
    else
      flash[:danger] = "There was a problem updating this program session."
      render :edit
    end

  end

  def new
    @program_session = @event.program_sessions.build
    authorize @program_session
    @speaker = @program_session.speakers.build
  end

  def create
    @program_session = @event.program_sessions.build(program_session_params)
    authorize @program_session
    @program_session.state = ProgramSession::INACTIVE
    @program_session.speakers.each { |speaker| speaker.event_id = @event.id }
    if @program_session.save
      redirect_to event_staff_program_session_path(@event,  @program_session)
      flash[:info] = "Program session was successfully created."
    else
      flash[:danger] = "Program session was unable to be saved: #{@program_session.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def destroy
    @program_session = @event.program_sessions.find(params[:id])
    authorize @program_session
    @program_session.destroy
    redirect_to event_staff_program_sessions_path(event)
    flash[:info] = "Program session was successfully deleted."
  end

  private

  def program_session_params
    params.require(:program_session).permit(:id, :session_format_id, :track_id, :title,
                                            :abstract, :state,
                                            speakers_attributes: [:id, :bio, :speaker_name, :speaker_email])
  end

end
