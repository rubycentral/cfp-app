class ApplicationController < ActionController::Base
  include Pundit
  include ActivateNavigation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  #after_action :verify_authorized, except: :index
  #after_action :verify_policy_scoped, only: :index

  require "csv"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_event
  helper_method :reviewer?
  helper_method :organizer?
  helper_method :event_staff?
  helper_method :display_staff_event_subnav?
  helper_method :display_staff_program_subnav?

  before_action :current_event
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout 'application'
  decorates_assigned :event

  def after_sign_in_path_for(user)
    if session[:pending_invite_accept_url]
      session[:pending_invite_accept_url]
    elsif !user.complete?
      edit_profile_path
    elsif request.referrer.present? && request.referrer != new_user_session_url
      request.referrer
    elsif user.admin?
      admin_events_path
    elsif user.proposals.any? #speaker
      proposals_path
    else
      root_path
    end
  end

  private

  def current_event
    @current_event ||= set_current_event(session[:current_event_id]) if session[:current_event_id]
  end

  def set_current_event(event_id)
    @current_event = Event.find_by(id: event_id).try(:decorate)
    session[:current_event_id] = @current_event.try(:id)
    @current_event
  end

  def pundit_user
    @pundit_user ||= CurrentEventContext.new(current_user, current_event)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:pending_invite_email])
  end

  def event_staff?(event)
    if event && current_user
      event.teammates.where(user_id: current_user.id).any?
    end
  end

  def reviewer?
    @is_reviewer ||= current_user.reviewer?
  end

  def organizer?
    @is_organizer ||= current_user.organizer?
  end

  def require_user
    unless user_signed_in?
      session[:target] = request.path
      flash[:danger] = "You must be signed in to access this page. If you haven't created an account, please create one."
      redirect_to new_user_session_url
    end
  end

  def require_event
    @event = Event.find_by(slug: params[:event_slug] || params[:slug])
    if @event
      set_current_event(event.id)
    else
      flash[:danger] = "Your event could not be found, please check the url."
      redirect_to events_path
    end
  end

  def require_proposal
    @proposal = @event.proposals.find_by!(uuid: params[:proposal_uuid] || params[:uuid])
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def event_params
    params.require(:event).permit(
        :name, :contact_email, :slug, :url, :valid_proposal_tags,
        :valid_review_tags, :custom_fields_string, :state, :guidelines,
        :closes_at, :speaker_notification_emails, :accept, :reject,
        :waitlist, :opens_at, :start_date, :end_date)
  end

  def render_json(object)
    send_data(render_to_string(json: object))
  end

  def set_title(title)
    @title = title[0..25] if title
  end

  def enable_staff_event_subnav
    @display_staff_subnav = true
  end

  def display_staff_event_subnav?
    @display_staff_subnav
  end

  def enable_staff_program_subnav
    @display_program_subnav = true
  end

  def display_staff_program_subnav?
    @display_program_subnav
  end

  def tracks
    @tracks ||= current_event.tracks
  end

  def set_proposal_counts
    @soft_accepted_count ||= Proposal.soft_accepted_count(current_event)
    @soft_waitlisted_count ||= Proposal.soft_waitlisted_count(current_event)
  end
end
