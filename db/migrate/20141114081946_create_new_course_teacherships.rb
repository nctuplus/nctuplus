class CreateNewCourseTeacherships < ActiveRecord::Migration
  def change
    create_table :new_course_teacherships do |t|
			t.integer :course_id
			t.integer :teacher_id
    end
  end
end
