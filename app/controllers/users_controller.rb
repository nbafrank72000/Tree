class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
  		@user.send_activation_email
  		flash[:success] = "Please check your email to activate your account."
  		redirect_to root_url
  	else
  		render 'new'
  	end
  end

  def show
  	@user = User.find(params[:id])
    @albums = @user.albums
  end

  def search
    @users = User.search(params[:search])
  end

  def friend
    @follow_users = User.all
    @followed_users = User.all
    #@follow_users = current_user.following.where(activated: true).paginate(page: params[:page])
    #@followed_users = current_user.followers.where(activated: true).paginate(page: params[:page])
  end

  private

  def user_params
  	params.require(:user).permit(:name, :email, :password, :password_confirmation, :headpic)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless correct_user?(@user)
  end


end
