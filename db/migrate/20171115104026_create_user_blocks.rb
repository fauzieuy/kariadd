class CreateUserBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :user_blocks do |t|
      t.integer :requestor_id
      t.integer :target_id

      t.timestamps
    end
    add_index :user_blocks, :requestor_id
    add_index :user_blocks, :target_id
  end
end
