class EventPolicy < ApplicationPolicy
  # class Scope
  #   def resolve
  #     scope
  #   end
  # end

  def initialize(user, model)
    @current_user = user
    @event = model
  end

  def index?
    @current_user.present? || @current_user.reviewer_events.where(slug: @event.slug).present?
  end

  def new?
    @current_user.admin? || @current_user.organizer_for_event?(@event)
  end

  def create?
    @current_user.admin?
  end

  def show?
    @event.present?
  end

  def edit?
    @current_user.admin? || @current_user.organizer_for_event?(@event)
  end

  def update?
    @current_user.admin? || @current_user.organizer_for_event?(@event)
  end

  def destroy?
    @current_user.admin? || @current_user.organizer_for_event?(@event)
  end

end


  # def index?
  #   false
  # end

  # def scope
  #   Pundit.policy_scope!(user, record.class)
  # end

  # class Scope
  #   attr_reader :user, :scope

  #   def initialize(user, scope)
  #     @user = user
  #     @scope = scope
  #   end

  #   def resolve
  #     scope
  #   end
  # end
