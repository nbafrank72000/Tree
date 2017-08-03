class AddStatusToRelationships < ActiveRecord::Migration[5.1]
  def change
  	add_column :relationships, :status, :integer, :default => 0
  	add_column :relationships, :past_status, :integer, :default => 0
  end
end
