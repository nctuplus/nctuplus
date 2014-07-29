class CreateSubDiscusses < ActiveRecord::Migration
  def change
    create_table :sub_discusses do |t|
			t.integer :user_id
			t.integer :discuss_id
			t.integer :likes
			t.integer :dislikes
			t.text :content
      t.timestamps
    end
		add_index :sub_discusses, :discuss_id
  end
		
end
