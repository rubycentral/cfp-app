class EventPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @event = model
  end

  def index?
    @current_user.admin? || @current_user.organizer_for_event?(@event)
  end

  def show?
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

  # def show?
  #   scope.where(:id => record.id).exists?
  # end

  # def create?
  #   false
  # end

  # def new?
  #   create?
  # end

  # def update?
  #   false
  # end

  # def edit?
  #   update?
  # end

  # def destroy?
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
