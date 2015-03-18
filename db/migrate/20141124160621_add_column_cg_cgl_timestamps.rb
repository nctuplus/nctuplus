class AddColumnCgCglTimestamps < ActiveRecord::Migration
  def change
  	add_timestamps(:course_groups)
  	add_timestamps(:course_group_lists)
  end
end
