class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ActivateNavigation
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_event
  helper_method :current_website
  helper_method :display_staff_event_subnav?
  helper_method :display_staff_selection_subnav?
  helper_method :display_staff_program_subnav?
  helper_method :display_website_subnav?
  helper_method :program_mode?
  helper_method :schedule_mode?
  helper_method :program_tracks

  before_action :set_paper_trail_whodunnit
  before_action :current_event
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout 'application'
  decorates_assigned :event

  private

  def after_sign_in_path_for(user)
    if session[:pending_invite_accept_url]
      session[:pending_invite_accept_url]
    elsif !user.complete?
      edit_profile_path
    elsif request.referrer.present? && (request.referrer != new_user_session_url) && (request.referrer != user_developer_omniauth_authorize_url)
      request.referrer
    elsif session[:target]
      session.delete(:target)
    elsif user.staff_for?(current_event)
      event_staff_path(current_event)
    elsif user.proposals.any?
      proposals_path
    elsif user.admin?
      admin_events_path
    elsif current_event
      event_path(current_event)
    else
      root_path
    end
  end

  def current_event
    @current_event ||= set_current_event(session[:current_event_id]) if session[:current_event_id]
  end

  def current_website
    @current_website ||= begin
      if current_event
        current_event.website
      elsif params[:slug]
        Website.joins(:event).find_by(events: { slug: params[:slug] })
      else
        older_domain_website || latest_domain_website
      end
    end&.decorate
  end

  def older_domain_website
    @older_domain_website ||=
      domain_websites.find_by(events: { slug: params[:domain_page_or_slug] })
  end

  def latest_domain_website
    @latest_domain_website ||= domain_websites.first
  end

  def domain_websites
    Website.domain_match(request.domain).joins(:event).order(created_at: :desc)
  end

  def set_current_event(event_or_event_id)
    event_or_event_id = Event.find_by(id: event_or_event_id) unless Event === event_or_event_id
    @current_event = event_or_event_id.try(:decorate)
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

  def require_user
    unless user_signed_in?
      session[:target] = request.path
      flash[:danger] = "You must be signed in to access this page. If you haven't created an account, please create one."
      redirect_to new_user_session_url
    end
  end

  def require_event
    slug = params[:event_slug] || params[:slug]
    @event = if @current_event && (@current_event.slug == slug)
      @current_event
    else
      Event.find_by(slug: params[:event_slug] || params[:slug])
    end
    if @event
      set_current_event(@event)
    else
      flash[:danger] = "Your event could not be found, please check the url."
      redirect_to events_path
    end
  end

  def require_website
    redirect_to not_found_path and return unless current_website
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

  def render_json(object, options={})
    send_data(render_to_string(json: object), options)
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

  def enable_staff_selection_subnav
    @display_selection_subnav = true
  end

  def display_staff_selection_subnav?
    @display_selection_subnav
  end

  def enable_staff_program_subnav
    @display_program_subnav = true
  end

  def display_staff_program_subnav?
    @display_program_subnav
  end

  def enable_staff_schedule_subnav
    @display_schedule_subnav = true
  end

  def display_website_subnav?
    @display_website_subnav
  end

  def enable_website_subnav
    @display_website_subnav = true
  end

  def program_mode?
    @display_program_subnav || @display_selection_subnav
  end

  def schedule_mode?
    @display_schedule_subnav
  end

  def program_tracks
    @program_tracks ||= current_event && current_event.tracks.any? ? current_event.tracks : []
  end

  def set_cache_headers
    return unless Rails.configuration.action_controller.perform_caching

    server_cache_age =
      current_website.caching_off? ? 0 : ENV.fetch('CACHE_CONTROL_S_MAXAGE', 1.week)

    expires_in(
      ENV.fetch('CACHE_CONTROL_MAX_AGE', 0).to_i,
      public: !current_website.caching_off?,
      's-maxage': server_cache_age.to_i
    )
    response.headers['Surrogate-Key'] = current_website.event.slug if FastlyService.service
    fresh_when(
      current_website,
      last_modified: current_website.purged_at || current_website.updated_at
    ) unless current_website.caching_off?
  end
end
