class CreateCourseTeacherPageContents < ActiveRecord::Migration
  def change
    create_table :course_teacher_page_contents do |t|
		t.integer :course_teachership_id
		t.integer :exam_record#, :limit=>18
		t.integer :homework_record#, :limit=>18
		t.text :course_note
		
		t.timestamps
    end
  end
end
