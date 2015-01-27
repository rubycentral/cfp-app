class NotificationsController < ApplicationController
  before_filter :require_user

  def index
    notifications = current_user.notifications.order(created_at: :desc)
    render locals: { notifications: notifications }
  end

  def show
    notification = current_user.notifications.find(params[:id])
    notification.read

    redirect_to notification.target_path
  end

  def mark_all_as_read
    current_user.notifications.where(read_at: nil).update_all(read_at: DateTime.now)
    redirect_to :back
  end
end
