class CreateTableRaiderContentList < ActiveRecord::Migration
  def change
    create_table :raider_content_lists do |t|
    	t.integer :course_teacher_page_content_id
    	t.integer :user_id
    	t.integer :type
    	t.text    :content
    	
    	t.timestamps
    end
  end
end
