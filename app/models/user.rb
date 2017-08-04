class User < ApplicationRecord
	has_many :albums, dependent: :destroy

	has_many :active_relationships, -> {where(status: 1)}, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :following, through: :active_relationships, source: :followed

	has_many :pended_relationships, -> {where(status: 2)}, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :pended, through: :pended_relationships, source: :followed
	
	has_many :passive_relationships, -> {where(status: 1)}, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
	has_many :followers, through: :passive_relationships, source: :follower
	
	has_many :pending_relationships, -> {where(status: 2)}, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
	has_many :pending, through: :pending_relationships, source: :follower
	
	#--------------------------------------------------------------------------------------------
	has_many :past_active_relationships, -> {where(past_status: 1)}, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :past_following, through: :past_active_relationships, source: :followed

	has_many :past_pended_relationships, -> {where(past_status: 2)}, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :past_pended, through: :past_pended_relationships, source: :followed

	has_many :past_passive_relationships, -> {where(past_status: 1)}, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
	has_many :past_followers, through: :past_passive_relationships, source: :follower

	has_many :past_pending_relationships, -> {where(past_status: 2)}, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
	has_many :past_pending, through: :past_pending_relationships, source: :follower

	attr_accessor :activation_token, :remember_token

	before_save :email_downcase
	before_create :create_activation_digest

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :name, presence:true, length: { maximum: 20 }
	validates :email, presence:true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, presence:true, length: { minimum: 6 }

	mount_uploader :headpic, HeadpicUploader

	class << self
		def new_token
			SecureRandom.urlsafe_base64
		end

		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end
	end

	def authenticated?(attribute, token)
			digest = self.send("#{attribute}_digest")
			return false if digest.nil?
			BCrypt::Password.new(digest).is_password?(token)
	end

	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def self.search(search)
  	if search
  		User.where("name LIKE ?", "%#{search}%")
    	#User.find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
  	else
    	User.find(:all)
  	end
	end

	#Judge if I am following other_user
	def following?(other_user)
		following.include?(other_user)
	end

	#Judge if other_user pending my follow request
	def pended?(other_user)
		pended.include?(other_user)
	end

	#Judge if I am followed by other_user 
	def follower?(other_user)
		followers.include?(other_user)
	end

	#Judge if I pending other_user follow request
	def pending?(other_user)
		pending.include?(other_user)
	end
	#-------------------------------------------------------------------------
	#Judge if I am following other_user past
	def past_following?(other_user)
		past_following.include?(other_user)
	end

	#Judge if other_user pending my follow request
	def past_pended?(other_user)
		past_pended.include?(other_user)
	end

	#Judge if I am followed by other_user 
	def past_follower?(other_user)
		past_followers.include?(other_user)
	end

	#Judge if I pending other_user follow request
	def past_pending?(other_user)
		past_pending.include?(other_user)
	end
	#-------------------------------------------------------------------------
	#Sending follow friend request, it will change relationship from 0(false) to 2(pending)
	def ask_follow(other_user)
		pended_relationships.create(followed_id: other_user.id)
	end

	def accept_past_request(other_user)
		#--------------------------------- P A S T -------------------------------VV#
		#-Still no past friend, need to reply being friend or not, so past_status is 2-#
		#----Want to Accept friend to follow us, through 'past_pending_relationship'---#
		puts 'accept_past_request'
		past_pending_relationships.find_by(follower_id: other_user.id).update(past_status: 1)
	end

	#Accept someone's request for follow me, it will change the relationship form 2(pending) to 1(ture)
	def update_response_side(other_user)
		if passive_relationships.find_by(follower_id: other_user.id).nil?
			#------------------------------ P R E S E N T ----------------------------#
			#---Still no friend, Pending other request to follow us, so status is 2---#
			#----Want to Accept friend to follow us, through 'pending_relationship'---#
			pending_relationships.find_by(follower_id: other_user.id).update(status: 1)
		else
				if past_passive_relationships.find_by(follower_id: other_user.id).nil?
					#------------------------------------ P A S T ---------------------------------#
					#-Still no past friend, need to reply being friend or not, so past_status is 2-#
					#----Want to Reject friend to follow us, through 'past_pending_relationship'---#
					past_pending_relationships.find_by(follower_id: other_user.id).update(past_status: 0)
				else
					#--------------------------------- P A S T -------------------------------#
					#---------------Is already past friend, so past_statis is 1---------------#
					#-Want to Reject friend to follow us, through 'past_passive_relationship'-#
					past_passive_relationships.find_by(follower_id: other_user.id).update(past_status: 0)
				end
		end
	end

	def update_request_side(other_user)
		if !past_active_relationships.find_by(followed_id: other_user.id).nil?
			#--------------------------------- P A S T -------------------------------#
			#-------------- If already past friend, so past_stauts is 1 --------------#
			#---------Want to Unfollow past, through 'past_active_relationship'-------#
			past_active_relationships.find_by(followed_id: other_user.id).update(past_status: 0)
		elsif past_pended_relationships.find_by(followed_id: other_user.id).nil?
			#--------------------------------- P A S T -------------------------------#
			#--------------Still no friend/pended, so past_status is 0----------------#
			#----Want to request other follow past, through 'active_relationship'-----#
			active_relationships.find_by(followed_id: other_user.id).update(past_status: 2)
		else
			#--------------------------------------------- P A S T ------------------------------------------#
			#----------------Still no friend, waiting friend's response, so past_status is 2-----------------#
			#----Want to Unfollow friend, giving up follow friend past, through 'past_pended_relationship'---#
			past_pended_relationships.find_by(followed_id: other_user.id).update(past_status: 0)
		end
	end

	#Reject other people to follow us, it will change the relationship from 2(pending) to 0(false)
	def reject_follow(other_user)
		if !past_pending_relationships.find_by(follower_id: other_user.id).nil?
			#----------------------------------- P A S T ----------------------------------#
			#-Still no past friend, need to reply being friend or not, so past_status is 2-#
			#----Want to Accept friend to follow us, through 'past_pending_relationship'---#
			puts "Do reject_follow action => accept past follow"
			past_pending_relationships.find_by(follower_id: other_user.id).update(past_status: 1)
		elsif passive_relationships.find_by(follower_id: other_user.id).nil?
			#----------------------------- P R E S E N T ----------------------------#
			#--Still not friend, need to reply being friend or not, so status is 2 --#
			#---Want to Reject friend to follow us, through 'pending_relationship'---#
			pending_relationships.find_by(follower_id: other_user.id).destroy
		else
			#---------------------------- P R E S E N T ---------------------------#
			#------------------ Is already friend, so status is 1 -----------------#
			#--Want to Reject friend to follow us, through 'passive_relationship'--#
			passive_relationships.find_by(follower_id: other_user.id).destroy
		end
	end

	#unfollow friend, delete the relationship
	def unfollow(other_user)
		if active_relationships.find_by(followed_id: other_user.id).nil?
			#---------------------------------- P R E S E N T --------------------------------#
			#----------Still not friend, waiting friend's response, so status is 2 -----------#
			#---Want to Unfollow friend, giving up to follow, through 'pended_relationship'---#
			pended_relationships.find_by(followed_id: other_user.id).destroy
		else
			#---------------------------- P R E S E N T ---------------------------#
			#------------------ Is already friend, so status is 1 -----------------#
			#--------Want to Unfollow friend, through 'active_relationship'--------#
			active_relationships.find_by(followed_id: other_user.id).destroy
		end
	end

	def feed
		Album.where("(user_id = ?) OR (user_id IN (?) AND past = ?) OR (user_id IN (?) AND past = ?)", id, following_ids, false, past_following_ids, true)
	end

	def feed_show
		Album.where("(user_id IN (?) AND past = ?) OR (user_id IN (?) AND past = ?)", following_ids, false, past_following_ids, true)
	end

	private

	def email_downcase
		self.email = email.downcase
	end

	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)
	end
end
