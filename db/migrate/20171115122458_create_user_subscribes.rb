class CreateUserSubscribes < ActiveRecord::Migration[5.1]
  def change
    create_table :user_subscribes do |t|
      t.integer :subscriber_id
      t.integer :publisher_id

      t.timestamps
    end
    add_index :user_subscribes, :subscriber_id
    add_index :user_subscribes, :publisher_id
  end
end
