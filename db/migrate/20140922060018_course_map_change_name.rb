class CourseMapChangeName < ActiveRecord::Migration
  def change
  	rename_column :course_fields, :course_map_id, :course_field_group_id
  end
end
