class AddCourseFieldIdToCourseSimulation < ActiveRecord::Migration
  def change
		add_column :course_simulations, :course_field_id, :integer
		add_index :course_simulations, :course_field_id
  end
end
