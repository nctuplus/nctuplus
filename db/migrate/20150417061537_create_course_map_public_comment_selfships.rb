class CreateCourseMapPublicCommentSelfships < ActiveRecord::Migration
  def change
    create_table :course_map_public_comment_selfships do |t|
			t.integer :parent_id
			t.integer :child_id
			t.timestamps
    end
  end
end
