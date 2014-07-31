class RenameTable < ActiveRecord::Migration
  def change
  	rename_column :course_content_lists, :course_teacher_page_content_id, :course_teachership_id
  	
  	remove_column :course_content_heads, :course_note
  	add_column :course_content_heads, :course_rollcall, :integer
  end
end
