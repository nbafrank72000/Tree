class StaticPagesController < ApplicationController
	
	def timeline
		@user = current_user
  	if logged_in?
  		@feed_items = current_user.feed
  	end
	end

	def profile
		@user = User.find(params[:id])
	end
end
