class WebsitePolicy < ApplicationPolicy
  def show?
    @user.organizer_for_event?(@current_event)
  end

  def new?
    show?
  end

  def create?
    show?
  end

  def edit?
    show?
  end

  def update?
    show?
  end
end
