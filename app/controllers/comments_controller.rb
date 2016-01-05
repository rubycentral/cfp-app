class CommentsController < ApplicationController
  def create
    @proposal = Proposal.find(comment_params[:proposal_id])

    comment_attributes = comment_params.merge(proposal: @proposal,
                                              person: current_user)

    case comment_type
    when 'PublicComment'
      @comment = @proposal.public_comments.create!(comment_attributes)
    when 'InternalComment'
      @comment = @proposal.internal_comments.create!(comment_attributes)
    else
      raise "Unknown comment type: #{comment_type}"
    end

    # email all reviers and organizers about the comment
    CommentNotificationMailer.email_notification(@comment).deliver_now

    # this action is used by the proposal show page for both speaker
    # and reviewer, so we reload the page they commented from
    redirect_to :back, info: "Your comment has been added"
  end

  private
  def comment_type
    params[:type] || 'PublicComment'
  end

  def comment_params
    params.require(comment_type.underscore).permit(:body, :proposal_id)
  end
end
