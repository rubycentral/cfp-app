class Staff::SponsorsController < Staff::ApplicationController

  def index
    @sponsors = current_event.sponsors
  end

  def new
    @sponsor = current_event.sponsors.build
  end

  def create
    @sponsor = current_event.sponsors.build(sponsors_params)

    flash[:success] = "Sponsor was successfully created."
    redirect_to event_staff_sponsors_path if @sponsor.save
  end

  def edit
    @sponsor = current_event.sponsors.find_by(id: params[:id])
  end

  def update
    @sponsor = current_event.sponsors.find_by(id: params[:id])
    @sponsor.update(sponsors_params)
    flash[:success] = "#{@sponsor.name} was successfully updated."
    redirect_to event_staff_sponsors_path
  end

  private
  def sponsors_params
    params.require(:sponsor).permit(:name, :tier, :published, :url, :other_title)
  end
end
