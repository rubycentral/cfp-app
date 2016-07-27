# Captures additional context for Pundit policies to make authorization decisions by.
class CurrentEventContext
  attr_reader :user, :current_event

  def initialize(user, current_event)
    @user = user
    @current_event = current_event
  end
end