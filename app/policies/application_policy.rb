class ApplicationPolicy
  attr_reader :user, :record, :current_event

  def initialize(context, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless context.try(:user)
    @user   = context.user
    @current_event = context.current_event
    @record = record
  end

  class ApplicationScope
    attr_reader :user, :scope

    def initialize(context, scope)
      @user = context.user
      @current_event = context.current_event
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
