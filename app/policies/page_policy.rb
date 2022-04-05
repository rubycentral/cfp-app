class PagePolicy < ApplicationPolicy
  def index?
    @user.staff_for?(@current_event)
  end
end
