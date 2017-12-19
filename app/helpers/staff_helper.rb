module StaffHelper

  def show_rating_form?(proposal, rating)
    !proposal.has_speaker?(current_user) && !ratings_closed?(proposal, rating)
  end

  def disable_rating_form?(proposal)
    proposal.withdrawn? || proposal.finalized?
  end

  def show_ratings?(proposal, rating)
    rating.persisted? || program_mode? || (proposal.finalized? && proposal.ratings.any?)
  end

  def ratings_closed?(proposal, rating)
    (proposal.finalized? && (!proposal.ratings.any? || !rating.persisted?)) || proposal.has_speaker?(current_user)
  end

  def allow_review?(proposal)
    (program_mode? || !proposal.has_speaker?(current_user)) && !proposal.finalized?
  end

  def show_proposal?(proposal)
    program_mode? || !proposal.has_speaker?(current_user)
  end

  def show_ratings_toggle?(proposal, rating)
    !program_mode? && !disable_rating_form?(proposal) && rating.new_record?
  end

  def show_destroy_rating?(proposal, rating)
    !disable_rating_form?(proposal) && !rating.new_record?
  end

  def program_tracker
    if program_mode?
      hidden_field_tag(:program, true)
    end
  end

end
