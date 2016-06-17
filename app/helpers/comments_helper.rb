module CommentsHelper
  def choose_class_for(comment)
    if comment.proposal.has_speaker?(comment.user)
      'speaker-comment'
    elsif comment.user.organizer_for_event?(comment.proposal.event)
      'organizer-comment'
    elsif comment.user.reviewer_for_event?(comment.proposal.event)
      'reviewer-comment'
    end
  end
end
