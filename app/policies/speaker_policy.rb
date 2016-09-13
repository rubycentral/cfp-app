class SpeakerPolicy < ApplicationPolicy

  def new?
    @user.organizer_for_event?(current_event)
  end

  def create?
    @user.organizer_for_event?(current_event)
  end

  def edit?
    @user.organizer_for_event?(current_event)
  end

  def update?
    @user.organizer_for_event?(current_event)
  end

  def destroy?
    @user.organizer_for_event?(current_event)
  end

end
