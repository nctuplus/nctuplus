class AddCosAndTeacherIdToCourseDetails < ActiveRecord::Migration
  def change
		add_column :course_details, :course_id, :integer, after: :id
		add_column :course_details, :teacher_id, :integer, after: :id
		add_index :course_details, :course_id
		add_index :course_details, :teacher_id
  end
end
