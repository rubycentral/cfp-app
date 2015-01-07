class Organizer::ProfilesController < Organizer::ApplicationController

  def edit
    @person = Speaker.find(params[:id]).person
  end

  def update
    @person = Speaker.find(params[:id]).person
    @person.update(person_params)
      redirect_to organizer_event_speakers_path(event)
    # else
    #   redirect_to edit_profile_organizer_event_speaker_path(event, speaker), danger: "Update failed; please try again later."
    # end
  end

  private

  def person_params
    params.require(:person).permit(:bio, :gender, :ethnicity, :country, :name, :email)
  end
end

