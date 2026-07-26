# Base controller for the mounted MissionControl::Jobs engine.
#
# The engine isolates its namespace, so bare route helpers resolve against the
# engine's own route set -- main app paths must go through `main_app`. That is
# why this cannot simply inherit from Admin::ApplicationController; the filters
# below mirror it with the prefix applied.
class MissionControlJobsController < ApplicationController
  before_action :require_user
  before_action :require_admin

  private

  def require_user
    return if user_signed_in?

    session[:target] = request.path
    redirect_to main_app.new_user_session_url,
                flash: { danger: "You must be signed in to access this page. If you haven't created an account, please create one." }
  end

  def require_admin
    return if current_user.admin?

    redirect_to main_app.events_path,
                flash: { danger: 'You must be signed in as an administrator to access this page.' }
  end
end
