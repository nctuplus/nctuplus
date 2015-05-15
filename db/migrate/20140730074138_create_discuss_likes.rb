class CreateDiscussLikes < ActiveRecord::Migration
  def change
    create_table :discuss_likes do |t|
			t.integer :user_id
			t.integer :discuss_id
			t.integer :sub_discuss_id
			t.boolean :like
      t.timestamps
    end
		add_index :discuss_likes, :discuss_id
		add_index :discuss_likes, :sub_discuss_id
		add_index :discuss_likes, :user_id
  end
end
