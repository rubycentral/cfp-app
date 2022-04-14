class PagePolicy < ApplicationPolicy
  def index?
    @user.organizer_for_event?(@current_event)
  end

  def new?
    index?
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def show?
    new?
  end

  def preview?
    new?
  end

  def publish?
    new?
  end
end
