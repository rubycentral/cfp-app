class CommentsController < ApplicationController
  before_action :require_user
  before_action :require_proposal
  before_action :require_comment_access

  def create
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
    redirect_back fallback_location: event_proposal_path(@proposal.event, @proposal)
  end

  private

  def require_proposal
    @proposal = Proposal.find(comment_params[:proposal_id])
  end

  # Public comments come from the proposal's speakers and the event staff, the
  # two pages that render the comment form. Internal comments are the staff's
  # private channel, which a speaker on the proposal must stay out of (cf.
  # Staff::ApplicationController#prevent_self_review).
  def require_comment_access
    permitted = if comment_type == 'InternalComment'
      current_user.staff_for?(@proposal.event) && !@proposal.has_speaker?(current_user)
    else
      @proposal.has_speaker?(current_user) || current_user.staff_for?(@proposal.event)
    end

    unless permitted
      redirect_to root_path, flash: {danger: 'You are not allowed to comment on the proposal you are trying to access.'}
    end
  end

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
