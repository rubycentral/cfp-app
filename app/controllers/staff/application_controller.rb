class Staff::ApplicationController < ApplicationController
  before_action :require_event
  before_action :require_staff

  helper_method :sticky_selected_track

  private

  # Must be an organizer on @event
  def require_staff
    unless event_staff?(current_event)
      session[:target] = request.path
      flash[:danger] = "You must be signed in as event staff to access this page."
      redirect_to root_path
    end
  end

  def require_contact_email
    if @event.contact_email.empty?
      session[:target] = request.path
      flash[:danger] = "You must set a contact email for this event before inviting teammates."
      redirect_to event_staff_edit_path(@event)
    end
  end

  def staff_signed_in?
    user_signed_in? && @event && (current_user.organizer_for_event?(@event) || current_user.reviewer_for_event?(@event))
  end

  def require_reviewer
    unless reviewer_signed_in?
      session[:target] = request.path
      flash[:danger] = "You must be signed in as an reviewer to access this page."
      redirect_to new_user_session_url
    end
  end

  def reviewer_signed_in?
    user_signed_in? && current_user.reviewer?
  end

  # Prevent reviewers from reviewing their own proposals.
  def prevent_self
    if @proposal.has_speaker?(current_user)
      flash[:notice] = "Can't review your own proposal!"
      redirect_to event_staff_proposals_url(event_slug: @proposal.event.slug)
    end
  end

  def sticky_selected_track
    session["event/#{current_event.id}/program/track"] if current_event
  end

  def sticky_selected_track=(id)
    session["event/#{current_event.id}/program/track"] = id if current_event
  end

end
