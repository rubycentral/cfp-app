class Organizer::ProfilesController < Organizer::ApplicationController

  def edit
    @person = Speaker.find(params[:id]).person
  end

  def update
    @person = Speaker.find(params[:id]).person
    if @person.update(person_params)
      redirect_to organizer_event_speakers_path(event)
    else
      flash[:danger] = "Unable to save profile."
      render :edit
    end
  end

  private

  def person_params
    params.require(:person).permit(:bio, :gender, :ethnicity, :country, :name, :email)
  end
end

