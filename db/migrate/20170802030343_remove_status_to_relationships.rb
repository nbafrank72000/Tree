class RemoveStatusToRelationships < ActiveRecord::Migration[5.1]
  def change
  	remove_column :relationships, :present_status
  	remove_column :relationships, :past_status
  end
end
