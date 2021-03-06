class UsersController < ApplicationController
  before_action :signed_in_user,  only: [:index, :edit, :update]
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: :destroy

  def show
    @user = User.find(params[:id])
    @cars = @user.cars.paginate(page: params[:page])
  end
 
  # Werid hack to only allow a/pag/:pag_id/user/:id path for api 
  def show_api
    @user = User.find(params[:id])
    @cars = @user.cars.paginate(page: params[:page])

    respond_to do |format|
      format.json { render json: @user.cars } 
    end
  end

  def new
    if signed_in?
      redirect_to root_url
    else
      @user = User.new
      
    end
  end
    
  def create
    if signed_in?
      redirect_to root_url
    else
      @user = User.new(user_params)
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to TrueCar!"
        redirect_to @user 
      else
        render 'new'
      end
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user    
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    if (current_user == user) && (current_user.admin?)
      flash[:error] = "Can't delete own admin account."
    else
      user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  private
    
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                    :password_confirmation)
    end

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in." 
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
  
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
