class CreateCourseMaps < ActiveRecord::Migration
  def change
    create_table :course_maps do |t|
    	t.integer :department_id
    	t.string :name
    	t.text :desc
    	t.integer :semester_id
    	t.integer :like
    	t.timestamps
    end
    create_table :course_fields do |t|
    	t.integer :course_map_id
    	t.string :name
    	t.text :credit_need
    	t.timestamps
    end
    
    create_table :course_field_lists do |t|
    	t.integer :course_field_id
    	t.integer :course_id
    	t.integer :teacher_id
    	t.integer :c_type
    	t.integer :user_id
    	
    	t.timestamps
    end
    
  end
end
