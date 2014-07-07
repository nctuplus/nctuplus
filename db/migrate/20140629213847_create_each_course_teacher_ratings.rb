class CreateEachCourseTeacherRatings < ActiveRecord::Migration
  def change
    create_table :each_course_teacher_ratings do |t|
		  t.integer :course_teacher_rating_id
			t.integer :user_id
			t.integer :score
			#t.string :rating_type
      t.timestamps
    end
		add_index :each_course_teacher_ratings, :course_teacher_rating_id
		add_index :each_course_teacher_ratings, :user_id

  end
end
