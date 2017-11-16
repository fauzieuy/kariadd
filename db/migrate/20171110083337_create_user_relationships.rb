class CreateUserRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :user_relationships do |t|
      t.integer :user_one_id
      t.integer :user_two_id

      t.timestamps
    end
    add_index :user_relationships, :user_one_id
    add_index :user_relationships, :user_two_id
  end
end
