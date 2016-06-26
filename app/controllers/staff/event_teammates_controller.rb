class Staff::EventTeammatesController < Staff::ApplicationController
  respond_to :html, :json

  def create
    user = User.where(email: params[:email]).first
    if user.nil?
      event_teammate_invitation =
        @event.event_teammate_invitations.build(event_teammate_params.merge(email: params[:email]))

      if event_teammate_invitation.save
        EventTeammateInvitationMailer.create(event_teammate_invitation).deliver_now
        flash[:info] = 'Event teammate invitation successfully sent.'
      else
        flash[:danger] = 'There was a problem creating your invitation.'
      end
      redirect_to event_staff_event_teammate_invitations_url(@event)
    else
      event_teammate = @event.event_teammates.build(event_teammate_params.merge(user: user))

      if event_teammate.save
        flash[:info] = 'Your event teammate was added.'
      else
        flash[:danger] = "There was a problem saving your event teammate. Please try again"
      end
      redirect_to event_staff_url(@event)
    end
  end

  def update
    event_teammate = EventTeammate.find(params[:id])
    event_teammate.update(event_teammate_params)

    flash[:info] = "You have successfully changed your event_teammate."
    redirect_to event_staff_url(@event)
  end

  def destroy
    @event.event_teammates.find(params[:id]).destroy

    flash[:info] = "Your event teammate has been deleted."
    redirect_to event_staff_url(@event)
  end

  def emails
    emails = User.where("email like ?",
                          "%#{params[:term]}%").order(:email).pluck(:email)
    respond_with emails.to_json, format: :json
  end

  private

  def event_teammate_params
    params.require(:event_teammate).permit(:role, :notifications)
  end
end
