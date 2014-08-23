class AddColumnIndexs < ActiveRecord::Migration
  def change
  	add_index :comments, :user_id
  	add_index :comments, :course_teachership_id
  	
  	add_index :course_teacher_page_contents, :course_teachership_id
  	
  	add_index :content_list_ranks, :raider_content_list_id
  	add_index :content_list_ranks, :user_id
  	
  	add_index :raider_content_lists, :course_teacher_page_content_id
  	add_index :raider_content_lists, :user_id
  end
end
