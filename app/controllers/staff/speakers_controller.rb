class Staff::SpeakersController < Staff::ApplicationController
  decorates_assigned :speaker
  before_action :set_program_session, only: [:new, :create]
  before_action :speaker_count_check, only: [:destroy]

  def index
    @program_speakers = current_event.speakers.in_program
  end

  def new
    @speaker = Speaker.new
  end

  def create
    s_params = speaker_params
    @speaker = @program_session.speakers.create(s_params.merge(event: current_event))
    authorize @speaker
    if @speaker.save
      flash[:success] = "#{@speaker.name} has been added to #{@program_session.title}"
      redirect_to event_staff_speakers_path(current_event)
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
  end

  def update
    @speaker = current_event.speakers.find(params[:id])
    authorize @speaker
    if @speaker.update(speaker_params)
      flash[:success] = "#{@speaker.name} was successfully updated"
      redirect_to event_staff_speakers_path(current_event)
    else
      flash[:danger] = "There was a problem updating this speaker."
      render :edit
    end
  end

  def destroy
    authorize @speaker
    if @speaker.destroy
      flash[:info] = "#{speaker.name} has been removed from #{speaker.program_session.title}."
      redirect_to event_staff_speakers_path(current_event)
    else
      flash[:danger] = "There was a problem removing #{speaker.name}."
      redirect_to event_staff_speakers_path(current_event)
    end
  end

  def emails
    emails = Proposal.where(id: params[:proposal_ids]).emails
    respond_to do |format|
      format.json { render json: {emails: emails} }
    end
  end

  private

  def speaker_params
    params.require(:speaker).permit(:bio, :email, :user_id, :event_id, :speaker_name, :speaker_email)
  end

  def set_program_session
    @program_session = current_event.program_sessions.find_by(id: params[:program_session_id])
  end

  def speaker_count_check
    @speaker = current_event.speakers.find(params[:id])
    unless @speaker.program_session.multiple_speakers?
      flash[:danger] = "Sorry, you can't remove the only speaker for a program session."
      redirect_to event_staff_speakers_path(current_event)
    end
  end
end
