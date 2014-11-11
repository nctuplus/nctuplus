class AddColumnCourseFieldGroup < ActiveRecord::Migration
  def change
  	add_column :course_field_groups, :group_type, :integer
  end
end
