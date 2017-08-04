class PhotosController < ApplicationController
	def create
    
  end

  def show
  	@photo = Photo.find(params[:id])
  end

  def destroy
  	@photo = Photo.find(params[:id])
    @photo.destroy
		redirect_to album_path(@photo.album_id)
  end

	private
    def photo_params
      params.require(:photo).permit(:album_id, :picture)
    end
end
