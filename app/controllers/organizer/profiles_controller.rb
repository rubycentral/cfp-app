class Organizer::ProfilesController < Organizer::ApplicationController

  def edit
    @person = Speaker.find(params[:id]).person
  end

  def update
    @person = Speaker.find(params[:id]).person
    if @person.update(person_params)
      redirect_to organizer_event_speakers_url(event)
    else
      if @person.email == ""
        @person.errors[:email].clear
        @person.errors[:email] = " can't be blank"
      end
      flash.now[:danger] = "Unable to save profile. Please correct the following: #{@person.errors.full_messages.join(', ')}."
      render :edit
    end
  end

  private

  def person_params
    params.require(:person).permit(:bio, :gender, :ethnicity, :country, :name, :email)
  end
end

