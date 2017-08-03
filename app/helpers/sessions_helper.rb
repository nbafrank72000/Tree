module SessionsHelper
	def log_in(user)
		session[:user_id] = user.id
	end

	def current_user
		if(user_id = session[:user_id])
			@current_user ||= User.find_by(id: user_id)
		elsif(user_id = cookies.signed[:user_id])
			user = User.find_by(id: user_id)
			if user && user.authenticated?(:remember, cookies[:remember_token])
				log_in(user)
				@current_user = user
				redirect_to user
			end
		end
	end

	def remember(user)
		user.remember
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end


	def log_out
		forget(current_user)	#have bug when calling current_user in 2 cases list is ‘Issue’ column of ‘delete a session’ below
		session.delete(:user_id)
		@current_user = nil
	end

	def logged_in?
		!current_user.nil?
	end

	def current_user?(user)
		user == current_user
	end

end
