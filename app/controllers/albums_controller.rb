class AlbumsController < ApplicationController
	before_action :logged_in_user, only: [:create, :destroy]
	before_action :correct_user, only: [:destroy]

	def new
		@album = current_user.albums.build if logged_in?
    @photo = @album.photos.build
	end

	def create
		@album = current_user.albums.build(album_params)
		#@photo = @album.photos.build

		#respond_to do |format|
			if @album.save
				#flash[:success] = "Gallery created!"
				#----------------------------------
				if !params[:photos].nil?
					params[:photos]['picture'].each do |a|
						@photo = @album.photos.create!(:picture => a, :album_id => @album.id)
					end
					flash[:success] = "Gallery created successful!"
					redirect_to current_user
				else
					flash[:warning] = "There are no photos in gallery! You can 'add photos' now or 'cancel'"
					redirect_to edit_album_path(@album)
				end
				#format.html{ redirect_to @gallery, notice: 'Gallery was created!'}
				#----------------------------------
				#redirect_to @gallery
				#redirect_to current_user
			else
				flash[:danger] = "Gallery created failed. Please enter gallery name!"
				redirect_to new_album__user
			end
	end

	def edit
		@album = Album.find(params[:id])
	end

	def update
		@album = Album.find(params[:id])
      if @album.update(album_params)
      	#flash[:success] = "Gallery created!"
				#----------------------------------
				if !params[:photos].nil?
					params[:photos]['picture'].each do |a|
						@photo = @album.photos.create!(:picture => a, :album_id => @album.id)
					end
					flash[:success] = "Album updated sucessful!"
					redirect_to @album
				else
					flash[:warning] = "Album updated failed. Please choose photos!"
					redirect_to edit_album_path(@album)
				end
				#format.html{ redirect_to @gallery, notice: 'Gallery was created!'}
				#----------------------------------
				#redirect_to @gallery
      else
      	flash[:danger] = "Album updated failed!"
				redirect_to edit_album_path(@album)
      end
	end

	def show
		@album = Album.find(params[:id])
		
    @photos = @album.photos.all
	end

	def destroy
		@album.destroy
		flash[:success] = "Album deleted"
		redirect_to request.referrer || current_user_path
	end

	def change_past_now
  	album = Album.find(params[:id])
  	if album.past
  		album.post_to_present
  	else
  		album.post_to_past
  	end
  	redirect_to current_user
  end

	private

	def album_params
		params.require(:album).permit(:name, :description, :past)
	end

	def correct_user
		@album = current_user.albums.find_by(id: params[:id])
		redirect_to current_user_path if @album.nil?
	end

end
