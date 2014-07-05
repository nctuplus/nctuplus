class CreateSemesterCourseships < ActiveRecord::Migration
  def change
    create_table :semester_courseships do |t|
	  t.integer :semester_id
	  t.integer :course_id
    t.timestamps
    end
	add_index :semester_courseships, :semester_id
	add_index :semester_courseships, :course_id	
  end
end
