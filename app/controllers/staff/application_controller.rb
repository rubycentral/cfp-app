class Staff::ApplicationController < ApplicationController
  before_action :require_event
  before_filter :require_staff

  private

  def require_event
    if current_user
      if current_user.admin?
        @event = Event.where(slug: params[:event_slug]).first
      else
        @event = current_user.reviewer_events.where(slug: params[:event_slug]).first
      end
    end
  end

  # Must be an organizer on @event
  def require_staff
    unless @event
      session[:target] = request.path
      flash[:danger] = "You must be signed in as event staff to access this page."
      redirect_to root_path
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
    if current_user.proposals.include?(@proposal)
      flash[:notice] = "Can't review your own proposal!"
      redirect_to event_staff_proposals_url(event_slug: @proposal.event.slug)
    end
  end

end
