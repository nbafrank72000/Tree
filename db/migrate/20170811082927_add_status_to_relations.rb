class AddStatusToRelations < ActiveRecord::Migration[5.1]
  def change
  	add_column :relations, :status, :integer
  end
end
