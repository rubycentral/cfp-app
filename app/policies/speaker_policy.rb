class SpeakerPolicy < ApplicationPolicy

  def create?
    @user.organizer_for_event?(current_event)
  end

  def update?
    @user.organizer_for_event?(current_event)
  end

  def destroy?
    @user.organizer_for_event?(current_event)
  end

end
