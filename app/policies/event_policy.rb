class EventPolicy < ApplicationPolicy
  # class Scope
  #   def resolve
  #     scope
  #   end
  # end

  def index?
    @user.present? || @user.reviewer_events.where(slug: @record.slug).present?
  end

  def new?
    @user.admin? || @user.organizer_for_event?(@record)
  end

  def create?
    @user.admin?
  end

  def show?
    @record.present?
  end

  def edit?
    @user.admin? || @user.organizer_for_event?(@record)
  end

  def update?
    @user.admin? || @user.organizer_for_event?(@record)
  end

  def destroy?
    @user.admin? || @user.organizer_for_event?(@record)
  end

  def staff?
    @user.reviewer_events.where(slug: @record.slug).present?
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
