class RemoveOldCourseField < ActiveRecord::Migration
  def change
  	drop_table :course_groups
  	drop_table :course_group_lists
  end
end
