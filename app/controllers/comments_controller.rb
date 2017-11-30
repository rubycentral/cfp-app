class CommentsController < ApplicationController
  def create
    @proposal = Proposal.find(comment_params[:proposal_id])

    comment_attributes = comment_params.merge(user: current_user)

    if comment_type == 'InternalComment'
      @comment = @proposal.internal_comments.create(comment_attributes)
    else
      @comment = @proposal.public_comments.create(comment_attributes)
    end

    unless @comment.valid?
      flash[:danger] = "Couldn't post comment: #{@comment.errors.full_messages.to_sentence}"
    end

    # this action is used by the proposal show page for both speaker
    # and reviewer, so we reload the page they commented from
    redirect_back fallback_location: event_proposal_path(@proposal.event, uuid: @proposal)
  end

  private
  def comment_type
    @comment_type ||= valid_comment_types.find{|t| t==params[:type]} || 'PublicComment'
  end

  def valid_comment_types
    @valid_comment_types ||= ['PublicComment', 'InternalComment']
  end

  def comment_params
    params.require(comment_type.underscore).permit(:body, :proposal_id)
  end
end
