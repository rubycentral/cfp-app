class NotificationsController < ApplicationController
  before_action :require_user

  def index
    notifications = current_user.notifications.order(created_at: :desc)
    render locals: { notifications: notifications }
  end

  def show
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read

    redirect_to notification.target_path
  end

  def mark_all_as_read
    current_user.notifications.where(read_at: nil).update_all(read_at: Time.current)
    flash[:notice] = "All notifications marked as read"
    redirect_to notifications_path
  end
end
