class CreateCourseManagers < ActiveRecord::Migration
  def change
    create_table :course_managers do |t|
	  t.integer :department_id
	  t.integer :user_id
      t.timestamps
    end
	add_index :course_managers, :department_id
	add_index :course_managers, :user_id
  end
end
