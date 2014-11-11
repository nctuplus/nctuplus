class CreateNewCourseDetails < ActiveRecord::Migration
  def change
    create_table :new_course_details do |t|
			t.integer :course_teachership_id
			t.integer :semester_id
			t.string :time
			t.string :room
			t.string :temp_cos_id
			t.string :brief
			t.text :memo
			t.string :reg_num
			t.string :students_limit
			#t.string :cos_type
			#t.string :credit
    end
		add_index :new_course_details, :semester_id	
		add_index :new_course_details, :course_teachership_id
  end
end
