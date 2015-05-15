class CreateCourseFieldSelfships < ActiveRecord::Migration
  def change
    create_table :course_field_selfships do |t|
	  t.integer :parent_id
	  t.integer :child_id
      t.timestamps
    end
	add_index :course_field_selfships, [:parent_id, :child_id]
	
  end
end
