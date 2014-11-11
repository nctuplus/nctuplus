class AddColumnCourseFieldListsCon < ActiveRecord::Migration
  def change
  	add_column :course_field_lists, :record_type, :boolean, :default=>true
  end
end
