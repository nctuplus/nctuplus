class CreateDiscussVerifies < ActiveRecord::Migration
  def change
    create_table :discuss_verifies do |t|
			t.integer :discuss_id
			t.integer :user_id
			t.boolean :pass
      t.timestamps
    end
		add_index :discuss_verifies, :discuss_id
		add_index :discuss_verifies, :user_id
  end
end
