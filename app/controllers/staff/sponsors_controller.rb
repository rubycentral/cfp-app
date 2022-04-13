class Staff::SponsorsController < Staff::ApplicationController

  def index
    @sponsors = current_event.sponsors
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  private
  def sponsors_params
    params.require(:sponsor).permit(:name, :tier, :published, :url, :other_title)
  end
end
