class Staff::ProposalReviewsController < Staff::ApplicationController
  before_action :track_program_use
  before_action :require_proposal, except: [:index]
  before_action :prevent_self_review, except: [:index]

  decorates_assigned :proposal, with: Staff::ProposalDecorator
  respond_to :html, :js

  def index
    authorize Proposal, :reviewer?
    set_title('Review Proposals')

    proposals = policy_scope(Proposal)
      .select("*,
        (#{Rating.select('score').where('proposal_id = proposals.id').where(user_id: current_user).to_sql}) as your_score,
        (#{Rating.select('COUNT(*)').where('proposal_id = proposals.id').to_sql}) as ratings_count,
        (#{Comment.select('COUNT(*)').where('proposal_id = proposals.id').to_sql}) as comments_count")
      .includes(:proposal_taggings, :review_taggings, :ratings, :session_format)

    proposals.to_a.sort_by! { |p| [p.ratings_count > 0 ? 1 : 0, p.created_at] }
    proposals = Staff::ProposalDecorator.decorate_collection(proposals)

    render locals: {
             proposals: proposals
           }
  end

  def show
    authorize @proposal, :review?
    set_title(@proposal.title)

    rating = current_user.rating_for(@proposal)
    rating.touch unless rating.new_record?

    current_user.notifications.mark_as_read_for_proposal(request.url)
    track_and_format_edit = current_user.reviewer_for_event?(current_event)
    visit_program_view = current_user.program_team_for_event?(current_event) && current_event.closed?

    @mention_names = current_event.mention_names

    render locals: {
      rating: rating,
      track_and_format_edit: track_and_format_edit,
      visit_program_view: visit_program_view
    }
  end

  def update
    if program_mode?
      authorize @proposal, :review_as_program_team?
    else
      authorize @proposal, :review?
    end
    tags = params[:proposal][:review_tags].downcase
    params[:proposal][:review_tags] = Tagging.tags_string_to_array(tags)

    unless @proposal.update(proposal_review_tags_params)
      flash[:danger] = 'There was a problem saving the proposal.'
    else
      @proposal.reload
    end
  end

  private

  def proposal_review_tags_params
    params.fetch(:proposal, {}).permit(review_tags: [])
  end

  def track_program_use
    if params[:program]
      enable_staff_program_subnav
    end
  end
end
