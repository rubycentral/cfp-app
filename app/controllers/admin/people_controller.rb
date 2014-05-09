class Admin::PeopleController < Admin::ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  # GET /admin/people
  def index
    render locals: { people: Person.includes(:participants) }
  end

  # GET /admin/people/1
  def show
    render locals: { person: @person }
  end

  # GET /admin/people/1/edit
  def edit
    render locals: { person: @person }
  end

  # PATCH/PUT /admin/people/1
  def update
    if @person.update(person_params)
      redirect_to admin_people_path, flash: { info: "#{@person.name} was successfully updated." }
    else
      render :edit, locals: { person: person }
    end
  end

  # DELETE /admin/people/1
  def destroy
    person_name = @person.name
    @person.destroy
    redirect_to admin_people_path, flash: { info: "#{person_name} was successfully destroyed." }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def person_params
      params.require(:person).permit(:bio, :gender, :ethnicity, :country,
                                     :name, :email)
    end
end
