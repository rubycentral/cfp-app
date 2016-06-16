class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :check_current_user, only: [:twitter, :github]

  def twitter
    authenticate_with_hash
  end

  def github
    authenticate_with_hash
  end

  def failure
    redirect_to new_user_session_url, danger: "There was an error authenticating you. Please try again."
  end

  private

  def check_current_user
    if current_user.present?
      flash[:info] = I18n.t("devise.failure.already_authenticated")
      redirect_to(events_url)
    end
  end

  def authenticate_with_hash
    logger.info "Authenticating user credentials: #{auth_hash.inspect}"
    @user = User.from_omniauth(auth_hash)

    if @user.persisted?
      flash.now[:info] = "You have signed in with #{auth_hash['provider'].capitalize}."
      assign_open_invitations if session[:invitation_slug].present?
      logger.info "Signing in user #{@user.inspect}"

      @user.skip_confirmation!
      sign_in @user

      if @user.complete?
        redirect_to (session.delete(:target) || events_url)
      else
        session[:need_to_complete] = true
        redirect_to edit_profile_url
      end
    else
      redirect_to new_user_session_url, danger: "There was an error authenticating via #{params[:provider].capitalize}."
    end
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def assign_open_invitations
    invitation = Invitation.find_by(slug: session[:invitation_slug])

    #binding.pry
    if invitation
      invitations = Invitation.where("LOWER(email) = ? AND state = ? AND user_id IS NULL",
                       invitation.email.downcase, Invitation::State::PENDING)
      invitations.each do |invitation|
        invitation.update_column(:user_id, current_user)
      end

    end
  end

end
