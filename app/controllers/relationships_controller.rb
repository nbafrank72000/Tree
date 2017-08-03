class RelationshipsController < ApplicationController
	before_action :logged_in_user
	
	def create
			user = User.find(params[:followed_id])	
			current_user.ask_follow(user)
			redirect_to friend_users_path
	end

	def update
		relation = Relationship.find(params[:id])
		user = relation.follower
		puts "user is #{user.id}"
		if !current_user?(user)
			puts "Go top"
		# if current_user.active_relationship.find_by(user.id).status != 1
			#- P R E S E N T - Accept others' follow request -  if status = 2, past_status = 0 (pending_relationship)                            --#
		# else
			#- P A S T - Accept others' follow past request  -  if status = 1, past_stauts = 2 (active_relationship & past_pending_relationship) --# This will mixed with next one so move to action 'destroy' 
			#- P A S T - Reject others' follow past request  -  if status = 1, past_status = 2 (active_relationship & past_pending_relationship) --#      <--------------------|
			#- P A S T - Reject others keep following past   -  if status = 1, past_status = 1 (active_relationship & past_passive_relationship) --#
			current_user.update_response_side(user)
			redirect_to friend_users_path
		else 
			puts "Go down"
			#- P A S T - Follow others past                 -  if status = 1, past_status = 0 (active_relationship)                             --#
			#- P A S T - Unfollow others past when pended   -  if status = 1, past_status = 2 (active_relationship & past_pended_relationship)  --#
			#- P A S T - Unfollow others past when friends  -  if status = 1, past_status = 1 (active_relationship & past_active_relationship)  --#
		# end
			user_reverse = relation.followed
			current_user.update_request_side(user_reverse)
			redirect_to friend_users_path
		end
	end

	def destroy
		relation = Relationship.find(params[:id])
		user = relation.followed
		if !current_user?(user)
		#- P R E S E N T - Unfollow others when friends - if status = 1, past_status = 0 (active_relationship) --#
		#- P R E S E N T - Unfollow others when pended  - if status = 2, past_status = 0 (pended_relationship) --#
			current_user.unfollow(user)
			redirect_to friend_users_path
		else
		#- P R E S E N T - Reject others keep following us - if stauts = 1, past_status = 0 (passive_relationship) --#
		#- P R E S E N T - Reject others following request - if status = 2, past_status = 0 (pending_relationship) --#
		#- P A S T - Accept others' follow past request  -  if status = 1, past_stauts = 2 (active_relationship & past_pending_relationship) --# This will moved from update due to mixed case'
		#-Description about above P A S T : Just ultilize method: :delete(destroy) in index.html.erb (line 86), that origitnal should be :patch(update), so in the fucntion 'reject_follow' that
		#- called by destroy, there are some if statement(line 181 in user.rb) to take this case in update behavior neither destroy behavior
			user_reverse = relation.follower
			current_user.reject_follow(user_reverse)
			redirect_to friend_users_path
		end
	end
end
