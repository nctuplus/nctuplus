class RemoveColumnFromCourseGroup < ActiveRecord::Migration
  def change
		remove_column :course_groups, :name
		remove_column :course_groups, :course_id
  end
end
