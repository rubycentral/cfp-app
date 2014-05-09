module CommentsHelper
  def choose_class_for(comment)
    if comment.proposal.has_speaker?(comment.person)
      'speaker-comment'
    elsif comment.person.organizer_for_event?(comment.proposal.event)
      'organizer-comment'
    elsif comment.person.reviewer_for_event?(comment.proposal.event)
      'reviewer-comment'
    end
  end
end
