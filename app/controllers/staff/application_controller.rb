class Staff::ApplicationController < ApplicationController
  before_action :require_user
  before_action :require_event
  before_action :require_staff

  private

  def require_staff
    unless current_user.staff_for?(current_event)
      redirect_to events_path, flash: {danger: 'You must be signed in as event staff to access this page.'}
    end
  end

  def prevent_self_review
    if !program_mode? && @proposal.has_speaker?(current_user)
      redirect_to event_staff_proposals_url(@proposal.event), flash: {notice: "Can't review your own proposal!"}
    end
  end

  def require_program_team
    unless current_user.program_team_for_event?(current_event)
      redirect_to event_staff_path(current_event), flash: {danger: 'You must be a member of the program team to access this page.'}
    end
  end

  def require_organizer
    unless current_user.organizer_for_event?(current_event)
      redirect_to event_staff_path(current_event), flash: {danger: 'You must be an organizer to access this page.'}
    end
  end
end
