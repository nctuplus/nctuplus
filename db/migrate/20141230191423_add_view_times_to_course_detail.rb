class AddViewTimesToCourseDetail < ActiveRecord::Migration
  def change
		add_column :course_details, :view_times, :integer, :default=>0
  end
end
