class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  class AuthHash < SimpleDelegator
    def account_name
      dig('info', 'nickname') || dig('extra', 'raw_info', 'screen_name')
    end

    def provider_name
      Identity::PROVIDER_NAMES[provider]
    end
  end

  before_action :link_identity_to_current_user, only: [:twitter, :github, :developer], if: -> { current_user }
  skip_forgery_protection only: :developer

  def twitter
    authenticate_with_hash
  end

  def github
    authenticate_with_hash
  end

  def developer
    user = User.find_by email: auth_hash.uid
    authenticate_with_hash user
  end

  def failure
    redirect_to new_user_session_url, danger: "There was an error authenticating you. Please try again."
  end

  private

  # If an already logged in user tries to connect with another provider, integrate with the current_user's identity
  def link_identity_to_current_user
    if (identity = Identity.find_by(provider: auth_hash.provider, uid: auth_hash.uid))
      if identity.user_id == current_user.id
        flash[:info] = "#{auth_hash.provider_name} is already connected to your account."
      else
        flash[:danger] = "This #{auth_hash.provider_name} account is already connected to another user."
      end
      redirect_to edit_profile_path
    elsif (legacy_user = User.find_by(provider: auth_hash.provider, uid: auth_hash.uid))
      # Found a legacy user - need to merge
      session[:pending_merge_user_id] = legacy_user.id
      session[:pending_merge_provider] = auth_hash.provider
      session[:pending_merge_uid] = auth_hash.uid
      session[:pending_merge_account_name] = auth_hash.account_name
      redirect_to merge_profile_path
    else
      current_user.identities.create!(provider: auth_hash.provider, uid: auth_hash.uid, account_name: auth_hash.account_name)
      flash[:info] = "Successfully connected #{auth_hash.provider_name} to your account."
      redirect_to edit_profile_path
    end
  end

  def authenticate_with_hash(user = nil)
    logger.info "Authenticating user credentials: #{auth_hash.inspect}"
    @user = user || User.from_omniauth(auth_hash, session[:pending_invite_email])

    if @user.persisted?
      flash.now[:info] = "You have signed in with #{auth_hash.provider_name}."
      logger.info "Signing in user #{@user.inspect}"

      @user.skip_confirmation!
      sign_in @user

      redirect_to after_sign_in_path_for(@user)
    else
      redirect_to new_user_session_url, danger: "There was an error authenticating via Auth provider: #{params[:provider]}."
    end
  end

  def auth_hash
    @auth_hash ||= AuthHash.new(request.env['omniauth.auth'])
  end
end
