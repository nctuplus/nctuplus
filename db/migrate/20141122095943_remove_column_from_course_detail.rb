class RemoveColumnFromCourseDetail < ActiveRecord::Migration
  def change
		remove_column :course_details, :course_id
		remove_column :course_details, :teacher_id
		add_column :course_details, :new_courseteachership_id, :integer
  end
end
