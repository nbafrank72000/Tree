class ChangeOwnedIdToRelation < ActiveRecord::Migration[5.1]
  def change
  	remove_column :relations, :onwed_id
  	add_column :relations, :owned_id, :string
  end
end
