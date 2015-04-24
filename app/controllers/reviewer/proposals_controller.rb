class Reviewer::ProposalsController < Reviewer::ApplicationController
  skip_before_filter :require_proposal, only: :index
  skip_before_filter :prevent_self, only: :index

  decorates_assigned :proposal, with: Reviewer::ProposalDecorator

  def index
    proposal_ids = current_user.proposals.pluck(:id)

    proposals = @event.proposals.includes(:proposal_taggings, :review_taggings,
      :ratings, :internal_comments, :public_comments).where.not(id: proposal_ids)

    proposals.to_a.sort_by! { |p| [ p.ratings.present? ? 1 : 0, p.created_at ] }
    proposals = Reviewer::ProposalDecorator.decorate_collection(proposals)

    render locals: {
      proposals: proposals
    }

  end

  def show
    set_title(@proposal.title)
    rating = current_user.rating_for(@proposal)

    render locals: {
      rating: rating
    }
    rating.touch unless rating.new_record?
  end

  def update
    unless @proposal.update_without_touching_updated_by_speaker_at(proposal_params)
      flash[:danger] = 'There was a problem saving the proposal.'
    end
    redirect_to :back
  end

  private

  def proposal_params
    params.fetch(:proposal, {}).permit({review_tags: []})
  end
end
