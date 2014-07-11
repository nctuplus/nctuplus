class CreateCourseTeacherRatings < ActiveRecord::Migration
  def change
    create_table :course_teacher_ratings do |t|
			t.integer :course_teachership_id
			t.integer :total_rating_counts
			t.float :avg_score
			t.string :rating_type
    end
		add_index :course_teacher_ratings, :course_teachership_id
  end
end
