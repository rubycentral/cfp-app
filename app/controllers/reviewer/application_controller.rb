class Reviewer::ApplicationController < ApplicationController

  before_filter :require_reviewer
  before_filter :require_event
  before_filter :require_proposal
  before_filter :prevent_self

  private
  def require_reviewer
    unless reviewer_signed_in?
      session[:target] = request.path
      flash[:danger] = "You must be signed in as an reviewer to access this page."
      redirect_to new_session_path
    end
  end

  def reviewer_signed_in?
    user_signed_in? && current_user.reviewer?
  end

  def require_event
    @event = current_user.reviewer_events.find(params[:event_id] || params[:id])
  end

  # Prevent reviewers from reviewing their own proposals
  def prevent_self
    if current_user.proposals.include?(@proposal)
      redirect_to reviewer_event_proposals_path
    end
  end
end
