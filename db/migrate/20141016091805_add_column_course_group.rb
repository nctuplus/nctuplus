class AddColumnCourseGroup < ActiveRecord::Migration
  def change
  	add_column :course_groups, :course_map_id, :integer, :default=>0
  end
end
