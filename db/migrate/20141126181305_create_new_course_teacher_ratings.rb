class CreateNewCourseTeacherRatings < ActiveRecord::Migration
  def change
    create_table :new_course_teacher_ratings do |t|
			t.integer :user_id
			t.integer :course_teachership_id
			t.integer :score
			t.integer :rating_type
      t.timestamps
    end
		add_index :new_course_teacher_ratings, :user_id
		add_index :new_course_teacher_ratings, :course_teachership_id
  end
end
