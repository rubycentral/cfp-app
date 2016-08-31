# Policy for Proposals, though for now covering blind review functionality.
class ProposalPolicy < ApplicationPolicy
  def reviewer_index?
    @user.staff_for?(@current_event)
  end

  def reviewer_show?
    @user.staff_for?(@current_event) && !@record.has_speaker?(@user)
  end

  def reviewer_update?
    @user.staff_for?(@current_event) && !@record.has_speaker?(@user)
  end

  def update_state?
    @user.program_team_for_event?(@current_event)
  end

  def finalize?
    @user.organizer_for_event?(@current_event)
  end

  def destroy?
    @user.organizer_for_event?(@current_event)
  end

  class Scope < ApplicationScope
    def resolve
      @current_event.proposals.not_withdrawn.not_owned_by(@user)
    end
  end
end
