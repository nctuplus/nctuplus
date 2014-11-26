class CreateNewCourseTeacherships < ActiveRecord::Migration
  def change
    create_table :new_course_teacherships do |t|
			t.integer :course_id
			t.string :teacher_id
    end
		add_index :new_course_teacherships, :course_id
  end
end
