class CreateCourseMapPublicSubComments < ActiveRecord::Migration
  def change
    create_table :course_map_public_sub_comments do |t|
			t.integer :user_id
			t.integer :course_map_public_comment_id
			t.integer :course_map_id
			t.string :comments
			t.timestamps
    end
  end
end
