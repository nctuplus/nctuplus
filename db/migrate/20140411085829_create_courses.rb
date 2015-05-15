class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
			t.string :ch_name
			t.string :eng_name
			t.integer :grade_id
			t.integer :department_id
			t.string :real_id
			t.float :rate
			t.timestamps
    end
	add_index :courses, :grade_id
	add_index :courses, :department_id
	add_index :courses, :real_id
  end
end
