class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :reviewer?

  layout 'application'
  decorates_assigned :event

  private
  def current_user
    @current_user ||= Person.find_by_id(session[:uid])
  end

  def reviewer?
    @is_reviewer ||= current_user.reviewer?
  end

  def user_signed_in?
    current_user.present?
  end

  def require_user
    unless user_signed_in?
      if params[:invitation_slug].present?
        session[:invitation_slug] = params[:invitation_slug]
        session[:target] = invitation_path(invitation_slug: params[:invitation_slug])
      else
        session[:target] = request.path
      end
      flash[:danger] = "You must be signed in to access this page. If you haven't created an account, please create one."
      redirect_to new_session_path
    end
  end

  def require_event
    @event = Event.find_by!(slug: params[:slug])
  end

  def require_proposal
    @proposal = @event.proposals.find_by!(uuid: params[:proposal_uuid] || params[:uuid])
  end

  def event_params
    params.require(:event).permit(:name, :contact_email, :slug, :url, :valid_proposal_tags, :valid_review_tags, :state, :guidelines, :closes_at, :speaker_notification_emails, :accept, :reject, :waitlist, :opens_at, :start_date, :end_date)
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def render_json(object)
    send_data(render_to_string(json: object))
  end

  def set_title(title)
    @title = title[0..25] if title
  end
end
