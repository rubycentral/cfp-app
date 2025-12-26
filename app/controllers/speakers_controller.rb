class SpeakersController < ApplicationController
  before_action :require_user

  def destroy
    speaker = Speaker.find_by!(id: params[:id])

    proposal = speaker.proposal
    speaker.destroy

    if current_user.id == speaker.user_id
      redirect_to root_path, status: :see_other, flash: {info: "You have withdrawn from #{proposal.title}."}
    else
      redirect_to [proposal.event, proposal], status: :see_other, flash: {info: "#{speaker.email} has been withdrawn from #{proposal.title}."}
    end
  end
end
