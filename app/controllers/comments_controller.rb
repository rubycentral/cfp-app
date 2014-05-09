class CommentsController < ApplicationController
  def create
    proposal = Proposal.find(comment_params[:proposal_id])

    comment_class.create(comment_params.merge(proposal: proposal,
                                              person: current_user))

    # this action is used by the proposal show page for both speaker
    # and reviewer, so we reload the page they commented from
    redirect_to :back, info: "Your comment has been added"
  end

  private
  def comment_type
    params[:type] || 'PublicComment'
  end

  def comment_class
    comment_type.constantize
  end

  def comment_params
    params.require(comment_type.underscore).permit(:body, :proposal_id)
  end
end
