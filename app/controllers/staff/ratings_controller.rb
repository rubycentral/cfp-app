class Staff::RatingsController < Staff::ApplicationController
  before_action :track_program_use
  before_action :require_proposal
  before_action :prevent_self_review

  respond_to :js

  decorates_assigned :proposal

  def create
    authorize @proposal, :rate?
    @rating = Rating.find_or_create_by(proposal: @proposal, user: current_user)
    @rating.update_attributes(rating_params)
    if @rating.save
      respond_with @rating, locals: {rating: @rating}
    else
      logger.warn("Error creating rating for proposal [#{@proposal.id}] for user [#{current_user.id}]: #{@rating.errors.full_messages}")
      render json: @rating.to_json, status: :bad_request
    end
  end

  def update
    authorize @proposal, :rate?

    @rating = current_user.rating_for(@proposal)
    if rating_params[:score].blank?
      @rating.destroy
      @rating = current_user.ratings.build(proposal: @proposal)
      respond_with :reviewer, locals: {rating: @rating}
      return
    end
    if @rating.update_attributes(rating_params)
      respond_with :reviewer, locals: {rating: @rating}
    else
      logger.warn("Error updating rating for proposal [#{@proposal.id}] for user [#{current_user.id}]: #{@rating.errors.full_messages}")
      render json: @rating.to_json, status: :bad_request
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score).merge(proposal: @proposal, user: current_user)
  end

  def track_program_use
    if params[:program]
      enable_staff_program_subnav
    end
  end
end
