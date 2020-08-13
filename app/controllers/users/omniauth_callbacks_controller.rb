class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :check_current_user, only: [:twitter, :github]

  def twitter
    authenticate_with_hash
  end

  def github
    authenticate_with_hash
  end

  def google_oauth2
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
    @user = User.from_omniauth(auth_hash, session[:pending_invite_email])

    if @user.persisted?
      flash.now[:info] = "You have signed in with #{auth_hash['provider'].capitalize}."
      logger.info "Signing in user #{@user.inspect}"

      @user.skip_confirmation!
      sign_in @user

      redirect_to after_sign_in_path_for(@user)

    else
      redirect_to new_user_session_url, danger: "There was an error authenticating via Auth provider: #{params[:provider]}."
    end
  end

  def auth_hash
    request.env['omniauth.auth']
  end

end
