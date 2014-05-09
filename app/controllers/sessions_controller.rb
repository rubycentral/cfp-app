class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create], if: -> { !Rails.env.production? }

  before_filter :require_user, only: [:destroy]

  def new
    if current_user
      redirect_to root_url
    else
      flash.now[:danger] = "We could not log you in right now - please try again later!" if params[:danger]
    end
  end

  def create
logger.info "Authenticating user credentials: #{auth_hash.inspect}"
    service, user = Person.authenticate(auth_hash, current_user)
    if user
      session[:uid] = user.id
      session[:sid] = service.id
logger.info "Session set to uid:#{session[:uid]}, sid:#{session[:sid]}"

      flash[:info] = "You have signed in with #{params[:provider].capitalize}."
logger.info "Signing in user #{user.inspect}"

      assign_open_invitations if session[:invitation_slug].present?

      if user.complete?
        redirect_to (session.delete(:target) || root_path)
      else
        session[:need_to_complete] = true
        # redirect_to edit_profile_path
        render 'profiles/edit'
      end
    else
      redirect_to new_session_path, danger: "There was an error authenticating via #{params[:provider].capitalize}."
    end
  end

  def destroy
    session[:uid] = nil
    session[:sid] = nil
    redirect_to :back, info: "You have signed out."
  end

  private
  def auth_hash
    request.env['omniauth.auth']
  end

  def assign_open_invitations
    invitation = Invitation.find_by(slug: session[:invitation_slug])

    if invitation
      Invitation.where("LOWER(email) = ? AND state = ? AND person_id IS NULL",
                       invitation.email.downcase,
                       Invitation::State::PENDING).each do |invitation|
        invitation.update_column(:person_id, current_user)
      end
    end
  end
end
