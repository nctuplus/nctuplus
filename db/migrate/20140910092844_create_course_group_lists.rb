class CreateCourseGroupLists < ActiveRecord::Migration
  def change
    create_table :course_group_lists do |t|
			t.integer :course_group_id
			t.integer :course_id
			t.integer :semester_id
			t.integer :course_type
			t.integer :user_id
			t.boolean :hidden
      t.timestamps
    end
		add_index :course_group_lists, :course_id
		add_index :course_group_lists, :semester_id
		add_index :course_group_lists, :course_group_id
		add_index :course_group_lists, :user_id
  end
end
