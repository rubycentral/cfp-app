class Admin::ApplicationController < ApplicationController
  before_action :require_user
  before_action :require_admin

  private

  def require_admin
    unless current_user.admin?
      flash[:danger] = "You must be signed in as an administrator to access this page."
      redirect_to events_path
    end
  end

end
