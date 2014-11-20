class CreateNewCourses < ActiveRecord::Migration
  def change
    create_table :new_courses do |t|
			t.string :real_id
			t.string :ch_name
			t.string :eng_name
			t.integer :credit
			t.integer :department_id
      t.timestamps
    end
  end
end
