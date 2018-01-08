class Staff::TeammatesController < Staff::ApplicationController
  before_action :enable_staff_event_subnav
  before_action :require_contact_email, only: [:create]
  respond_to :html, :json

  def index
    @staff = TeammateDecorator.decorate_collection(current_event.teammates.accepted.alphabetize)
    @invitations = current_event.teammates.invitations

    @staff_count = group_count(@staff)
    @pending_invite_count = group_count(@invitations.where(state: "pending"))
  end

  def create #creating an invitation
    invitation = current_event.teammates.build(params.require(:teammate).permit(:email, :role, :mention_name))

    if invitation.invite
        TeammateInvitationMailer.create(invitation).deliver_now
      redirect_to event_staff_teammates_path(current_event),
        flash: { info: "Invitation to #{invitation.email} was sent."}
    else
      redirect_to event_staff_teammates_path(current_event),
        flash: { danger: "There was a problem sending your invitation. #{invitation.errors.full_messages.to_sentence}" }
    end
  end

  def update
    teammate = current_event.teammates.find(params[:id])
    teammate.update(params.require(:teammate).permit(:role, :notifications, :mention_name))
    if teammate.save
      respond_to do |format|
        format.html do
          redirect_to event_staff_teammates_path(current_event)
        end
        format.js do
          render locals: { teammate: teammate }
        end
      end
    else
      redirect_to event_staff_teammates_path(current_event),
        flash: { danger: "There was a problem updating #{teammate.name}. #{teammate.errors.full_messages.join(", ")}." }
    end
  end

  def destroy
    teammate = current_event.teammates.find(params[:id])
    if teammate.destroy
      redirect_to event_staff_teammates_path(current_event),
        flash: { info: "#{teammate.email} was removed." }
    else
      redirect_to event_staff_teammates_path(current_event),
        flash: { danger: "There was a problem removing #{teammate.email}." }
    end
  end

  private

  def group_count(group)
    team_counts = {"organizer" => 0, "program team" => 0, "reviewer" => 0}
    group.each { |t| team_counts[t.role] += 1 }
    team_counts
  end

  def require_contact_email
    if current_event.contact_email.empty?
      flash[:danger] = "You must set a contact email for this event before inviting teammates."
      redirect_to event_staff_edit_path(@event)
    end
  end

end
