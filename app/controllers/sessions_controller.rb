class SessionsController < ApplicationController
	before_action :current_user, only: [:new]

  def new
  	if logged_in?
  		redirect_to current_user
  	else
  		render 'new'
  	end
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		if user.activated?
  			log_in(user)
				params[:session][:remember_me] == '1' ? remember(user) : forget(user)
				redirect_back_or static_pages_timeline_url
			else
				message = "Account not activated."
				message += "Check your email for activation link."
				flash[:warning] = message
				redirect_to root_url
			end
  	else
  		flash.now[:danger] = 'Invalid email/password combination'
  		render 'new'
  	end
  end

  def destroy
  	log_out if logged_in?
  	redirect_to root_url
  end

end
