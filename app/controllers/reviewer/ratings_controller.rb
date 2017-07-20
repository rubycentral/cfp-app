class Reviewer::RatingsController < Reviewer::ApplicationController
  respond_to :js

  decorates_assigned :proposal

  def create
    @rating = Rating.find_or_create_by(proposal: @proposal, person: current_user)
    @rating.update_attributes(rating_params)
    if @rating.save
      respond_with @rating, locals: {rating: @rating}
    else
      logger.warn("Error creating rating for proposal [#{@proposal.id}] for person [#{current_user.id}]: #{@rating.errors.full_messages}")
      render json: @rating.to_json, status: :bad_request
    end
  end

  def update
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
      logger.warn("Error updating rating for proposal [#{@proposal.id}] for person [#{current_user.id}]: #{@rating.errors.full_messages}")
      render json: @rating.to_json, status: :bad_request
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score).merge(proposal: @proposal, person: current_user)
  end
end
