class CreateCourseGroups < ActiveRecord::Migration
  def change
    create_table :course_groups do |t|
			t.string :title
			t.string :description
			t.integer :department_id
			t.integer :user_id
			t.integer :credit_needed
			t.integer :adopt_times
      t.timestamps
    end
		add_index :course_groups, :user_id
		add_index :course_groups, :department_id
		
  end
end
