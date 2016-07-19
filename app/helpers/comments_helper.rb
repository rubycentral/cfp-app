module CommentsHelper
  def choose_class_for(comment)
    if comment.proposal.has_speaker?(comment.user)
      'by_myself right speaker-comment'
    elsif comment.user.organizer_for_event?(comment.proposal.event)
      'from_user left organizer-comment'
    elsif comment.user.reviewer_for_event?(comment.proposal.event)
      'from_user left reviewer-comment'
    end
  end
end
