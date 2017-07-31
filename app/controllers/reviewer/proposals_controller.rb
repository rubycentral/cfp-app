class Reviewer::ProposalsController < Reviewer::ApplicationController
  skip_before_filter :require_proposal, only: :index
  skip_before_filter :prevent_self, only: :index

  decorates_assigned :proposal, with: Reviewer::ProposalDecorator
  respond_to :html, :js


  def index
    proposal_ids = current_user.proposals.pluck(:id)

    proposals = @event.proposals.not_withdrawn.includes(:proposal_taggings, :review_taggings,
                                                        :ratings, :internal_comments, :public_comments).where.not(id: proposal_ids)

    proposals.to_a.sort_by! { |p| [p.ratings.present? ? 1 : 0, p.created_at] }
    proposals = Reviewer::ProposalDecorator.decorate_collection(proposals)

    render locals: {
             proposals: proposals
           }

  end

  def show
    set_title(@proposal.title)
    rating = current_user.rating_for(@proposal)
    current_user.notifications.mark_as_read_for_proposal(request.url)
    render locals: {
             rating: rating
           }
    rating.touch unless rating.new_record?
  end

  def update
      unless @proposal.update_without_touching_updated_by_speaker_at(proposal_params)
        flash[:danger] = 'There was a problem saving the proposal.'
      else
        flash[:info] = 'Review Tags were saved for this proposal'
      end
    end

    private

    def proposal_params
      params.fetch(:proposal, {}).permit({review_tags: []})
    end
end
