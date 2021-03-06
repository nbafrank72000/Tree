class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:update]

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      @user.update_attribute(:activated, true)
  		#@user.send_activation_email
  		flash[:success] = "Please check your email to activate your account."
  		redirect_to root_url
  	else
  		render 'new'
  	end
  end

  def show
  	@user = User.find(params[:id])
    if current_user?(@user)
      @albums = @user.albums
    else
      @albums = current_user.feed_show
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def search
    @users = User.search(params[:search])
  end

  def friend
    #@follow_users = User.all
    #@followed_users = User.all
    @follow_users = current_user.following.where(activated: true)
    @pended_users = current_user.pended.where(activated: true)
    @followed_users = current_user.followers.where(activated: true)
    @pending_users = current_user.pending.where(activated: true)
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers
    render 'show_follow'
  end

  private

  def user_params
  	params.require(:user).permit(:name, :email, :password, :password_confirmation, :headpic)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless @user == current_user
  end


end
