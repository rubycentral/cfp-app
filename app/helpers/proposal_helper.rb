module ProposalHelper
  def rating_tooltip
      <<-HTML
      <p><strong>Ratings Guide</strong></p>
     <p> 1 - Poor talk with many issues. Not a fit for the event.</p>
     <p> 2 - Mediocre talk that might fit event if they work on it.</p>
     <p> 3 - Good talk, could use improvement but appropriate for the event.</p>
     <p> 4 - Great talk, on topic and an overall fit for the event.</p>
     <p> 5 - Ideal talk, excellent proposal that is a perfect fit for the event.</p>
      HTML
  end

  def session_format_tooltip
    "The format your proposal will follow."
  end

  def track_tooltip
    "Optional: suggest a specific track to be considered for."
  end

  def abstract_tooltip
    "A concise, engaging description for the public program. Limited to 600 characters."
  end

  def details_tooltip
    "Include any pertinent details such as outlines, outcomes or intended audience."
  end

  def pitch_tooltip
    "Explain why this talk should be considered and what makes you qualified to speak on the topic."
  end

  def bio_tooltip
    "Your bio should be short, no longer than 500 characters. It's related to why you're speaking about this topic."
  end

  def notes_tooltip
    "Please note any scheduling conflicts, or any additional information an organizer may need to schedule your talk."
  end

end
