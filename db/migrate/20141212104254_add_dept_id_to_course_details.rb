class AddDeptIdToCourseDetails < ActiveRecord::Migration
  def change
		add_column :course_details, :department_id, :integer, after: :course_teachership_id
		remove_column :course_details, :unique_id
		add_index :course_details, :department_id
  end
end
