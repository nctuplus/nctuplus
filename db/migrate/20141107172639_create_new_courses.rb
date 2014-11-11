class CreateNewCourses < ActiveRecord::Migration
  def change
    create_table :new_courses do |t|
			t.string :unique_id
			t.string :real_id
			t.string :ch_name
			t.string :eng_name
			t.string :cos_type
			t.integer :degree
			t.integer :grade_id
			t.integer :department_id
      t.timestamps
    end
  end
end
