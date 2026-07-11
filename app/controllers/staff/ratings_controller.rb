class Staff::RatingsController < Staff::ApplicationController
  before_action :track_program_use
  before_action :require_proposal
  before_action :prevent_self_review

  private decorates_assigned :proposal

  def create
    authorize @proposal, :rate?

    @rating = Rating.find_or_initialize_by(proposal: @proposal, user: current_user)
    @rating.update!(rating_params)

    # The first rating reveals the internal comments; replace the whole widget.
    render_rating_widget
  end

  def update
    authorize @proposal, :rate?

    @rating = current_user.rating_for(@proposal)
    if rating_params[:score].blank?
      @rating.destroy
      @rating = current_user.ratings.build(proposal: @proposal)
      # Removing the rating re-hides the internal comments; replace the whole widget.
      render_rating_widget
      return
    end

    @rating.update!(rating_params)
    # A score change must not touch the internal comments (a draft may be in
    # progress there); replace only the rating form's own frame.
    render turbo_stream: turbo_stream.replace(
      helpers.dom_id(@proposal, :rating_form),
      partial: 'shared/proposals/rating_form_frame',
      locals: {event: @proposal.event, proposal: @proposal, rating: @rating}
    )
  end

  private

  def render_rating_widget
    render turbo_stream: turbo_stream.replace(
      helpers.dom_id(@proposal, :rating_widget),
      partial: 'shared/proposals/rating_widget',
      locals: {event: @proposal.event, proposal: @proposal, rating: @rating}
    )
  end

  def rating_params
    params.require(:rating).permit(:score).merge(proposal: @proposal, user: current_user)
  end

  def track_program_use
    if params[:program]
      enable_staff_program_subnav
    end
  end
end
