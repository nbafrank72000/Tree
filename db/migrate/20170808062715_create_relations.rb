class CreateRelations < ActiveRecord::Migration[5.1]
  def change
    create_table :relations do |t|
    	t.integer :owner_id
    	t.integer :owned_id

      t.timestamps
    end
    add_index :relations, :owner_id
    add_index :relations, :owned_id
    add_index :relations, [:owner_id, :owned_id], unique: true
  end
end
