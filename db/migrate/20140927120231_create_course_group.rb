class CreateCourseGroup < ActiveRecord::Migration
  def change
    create_table :course_groups do |t|
    	t.string :name
    	t.integer :course_id
    	t.integer :user_id
    end
    
    create_table :course_group_lists do |t|
    	t.integer :course_group_id
    	t.integer :course_id
    	t.integer :user_id
    end
  end
end
