class CreateAlbums < ActiveRecord::Migration[5.1]
  def change
    create_table :albums do |t|
      t.string :name
      t.text :description
      t.boolean :past, default: true
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :albums, [:user_id, :created_at]
  end
end
