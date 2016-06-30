class Admin::ApplicationController < ApplicationController

  before_filter :require_admin

  private
  def require_admin
    unless admin_signed_in?
      session[:target] = request.path
      flash[:danger] = "You must be signed in as an administrator to access this page."
      redirect_to new_user_session_url
    end
  end

  def admin_signed_in?
    user_signed_in? && current_user.admin?
  end

end
