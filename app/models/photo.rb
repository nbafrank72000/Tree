class Photo < ApplicationRecord
	belongs_to :album
  mount_uploader :picture, PictureUploader
  validates :picture, presence: true
  validates :album_id, presence: true
end
