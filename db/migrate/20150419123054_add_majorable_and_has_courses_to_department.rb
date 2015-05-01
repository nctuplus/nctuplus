class AddMajorableAndHasCoursesToDepartment < ActiveRecord::Migration
  def change
		add_column :departments, :has_courses, :boolean, :default=>false, :nil=>false, :after=> "eng_name"
		add_column :departments, :majorable, :boolean, :default=>false, :nil=>false, :after=> "has_courses"
  end
end
