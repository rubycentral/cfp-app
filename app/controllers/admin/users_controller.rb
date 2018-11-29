class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /admin/users
  def index
    render locals: { users: User.includes(:teammates) }
  end

  # GET /admin/users/1
  def show
    render locals: { user: @user }
  end

  # GET /admin/users/1/edit
  def edit
    render locals: { user: @user }
  end

  # PATCH/PUT /admin/users/1
  def update
    @user.skip_reconfirmation!
    if @user.update(user_params)
      redirect_to admin_users_url, flash: { info: "#{@user.name} was successfully updated." }
    else
      render :edit, locals: { user: @user }
    end
  end

  # DELETE /admin/users/1
  def destroy
    @user.destroy
    redirect_to admin_users_url, flash: { info: "User account for #{@user.name} was successfully deleted." }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:bio, :gender, :ethnicity, :country, :name, :email)
    end
end
