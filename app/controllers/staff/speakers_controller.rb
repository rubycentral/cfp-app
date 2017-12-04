class Staff::SpeakersController < Staff::ApplicationController
  include ProgramSupport

  before_action :set_program_session, only: [:new, :create]
  before_action :speaker_count_check, only: [:destroy]
  before_action :enable_staff_program_subnav

  def index
    @program_speakers = current_event.speakers.in_program
  end

  def new
    @speaker = Speaker.new
    authorize @speaker
  end

  def create
    s_params = speaker_params
    @speaker = @program_session.speakers.create(s_params.merge(event: current_event))
    authorize @speaker
    if @speaker.save
      redirect_to event_staff_program_session_path(current_event, @program_session)
    else
      flash[:danger] = "There was a problem saving this speaker."
      render :new
    end
  end

  def show
    @speaker = current_event.speakers.find(params[:id])
  end

  def edit
    @speaker = current_event.speakers.find(params[:id])
    authorize @speaker
  end

  def update
    @speaker = current_event.speakers.find(params[:id])
    authorize @speaker
    if @speaker.update(speaker_params)
      flash[:success] = "#{@speaker.name} was successfully updated" # not all edits are visible on the next screen
      redirect_to event_staff_program_speakers_path(current_event)
    else
      flash[:danger] = "There was a problem updating this speaker."
      render :edit
    end
  end

  def destroy
    authorize @speaker
    if @speaker.destroy
      redirect_to event_staff_program_session_path(current_event, @speaker.program_session)
    else
      flash[:danger] = "There was a problem removing #{@speaker.name}."
      redirect_to event_staff_program_session_path(current_event, @speaker.program_session)
    end
  end

  private

  def speaker_params
    params.require(:speaker).permit(:bio, :email, :user_id, :event_id, :speaker_name, :speaker_email)
  end

  def set_program_session
    @program_session = current_event.program_sessions.find_by(id: params[:session_id])
  end

  def speaker_count_check
    @speaker = current_event.speakers.find(params[:id])
    unless @speaker.program_session.multiple_speakers?
      flash[:danger] = "Sorry, you can't remove the only speaker for a program session."
      redirect_to event_staff_program_speakers_path(current_event)
    end
  end
end
