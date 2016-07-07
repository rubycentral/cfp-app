class Staff::TeamController < Staff::ApplicationController
  skip_before_filter :require_proposal, only: [:update], if: proc {|c| current_user && current_user.reviewer? }
  respond_to :html, :json

  def index
    @staff = current_event.event_teammates
    @invitations = current_event.event_teammate_invitations

    @staff_count = group_count(@staff)
    @invite_count = group_count(@invitations)
  end

  def update
    teammate = current_event.event_teammates.find(params[:id])
    teammate.update(params.require(:event_teammate).permit(:role, :notifications))
    if teammate.save
    # do we use both html and js formats?
      respond_to do |format|
        format.html do
          redirect_to event_staff_team_index_path(current_event),
            flash: { info: "You have successfully updated #{pluralize(teammate.name)} role." }
        end
        format.js do
          render locals: { event_teammate: event_teammate }
        end
      end
    else
      redirect_to event_staff_team_index_path(current_event),
        flash: { danger: "There was a problem updating #{pluralize(teammate.name)} role." }
    end
  end

  def destroy
    teammate = current_event.event_teammates.find(params[:id])
    if teammate.destroy
      redirect_to event_staff_team_index_path(current_event),
        flash: { info: "#{teammate.name} was removed." }
    else
      redirect_to event_staff_team_index_path(current_event),
        flash: { danger: "There was a problem removing #{teammate.name}." }
    end
  end

  private

  def group_count(group)
    team_counts = {"organizer" => 0, "program team" => 0, "reviewer" => 0}
    group.each { |t| team_counts[t.role] += 1 }
    team_counts
  end

end
