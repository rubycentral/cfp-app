module StaffHelper

  def allow_rating?(proposal)
    (program_mode? || !proposal.has_speaker?(current_user)) && !proposal.finalized?
  end

  def show_ratings?(rating)
    program_mode? || rating.persisted?
  end

  def allow_review?(proposal)
    (program_mode? || !proposal.has_speaker?(current_user)) && !proposal.finalized?
  end

  def show_proposal?(proposal)
    program_mode? || !proposal.has_speaker?(current_user)
  end

  def program_tracker
    if program_mode?
      hidden_field_tag(:program, true)
    end
  end

end
