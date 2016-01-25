class Reviewer::ProposalDecorator < ProposalDecorator
  decorates :proposal

  def title_link
    link = h.link_to h.truncate(object.title, length: 45),
                     h.reviewer_event_proposal_path(object.event, object)

    link += state_label(small: true) if object.withdrawn?

    link
  end

  def created_at
    object.created_at.to_s(:short)
  end

  def updated_at
    object.updated_at.to_s(:short)
  end

  def comment_count
    proposal.internal_comments.size + proposal.public_comments.size
  end

  def internal_comments_style
    object.was_rated_by_person?(h.current_user) ? nil : "display: none;"
  end

  def rating_tooltip
    <<-HTML
      <p>Ratings Guide</p>
     <p> 1 - Poor talk with many issues. Not a fit for the event.</p>
     <p> 2 - Mediocre talk that might fit event if they work on it.</p>
     <p> 3 - Good talk, could use improvement but appropriate for the event.</p>
     <p> 4 - Great talk, on topic and an overall fit for the event.</p>
     <p> 5 - Ideal talk, excellent proposal that is a perfect fit for the event.</p>
    HTML
  end
end
