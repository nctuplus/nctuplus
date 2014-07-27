class AddColumnCourseteacherpagecontents < ActiveRecord::Migration
  def change
  	add_column :course_teacher_page_contents, :last_user_id, :integer
  end
end
