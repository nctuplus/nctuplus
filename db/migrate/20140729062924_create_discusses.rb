class CreateDiscusses < ActiveRecord::Migration
  def change
    create_table :discusses do |t|
			t.integer :user_id
			t.integer :course_teachership_id
			t.integer :likes
			t.integer :dislikes
			t.string :title
			t.text :content
      t.timestamps
    end
		add_index :discusses, :user_id
		add_index :discusses, :course_teachership_id
  end
end
