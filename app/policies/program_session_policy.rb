class ProgramSessionPolicy < ApplicationPolicy

  def index?
    @user.program_team_for_event?(@current_event)
  end

  def show?
    @user.program_team_for_event?(@current_event)
  end

  def edit?
    @user.organizer_for_event?(@current_event)
  end

  def update?
    @user.organizer_for_event?(@current_event)
  end

  def new?
    @user.organizer_for_event?(@current_event)
  end

  def create?
    @user.organizer_for_event?(@current_event)
  end

  def update_state?
    @user.organizer_for_event?(@current_event)
  end


  def confirm_for_speaker?
    @user.organizer_for_event?(@current_event)
  end
  
  def promote?
    @user.organizer_for_event?(@current_event)
  end

  def destroy?
    @user.organizer_for_event?(@current_event)
  end

end