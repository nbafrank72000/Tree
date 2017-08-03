class AddAlbumIdToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :album_id, :integer
  end
end
