class CreateCourseSimulations < ActiveRecord::Migration
  def change
    create_table :course_simulations do |t|
	  t.integer :user_id
		t.integer :semester_id
	  t.integer :course_detail_id
    t.timestamps
    end
	add_index :course_simulations, :user_id
	add_index :course_simulations, :semester_id
	add_index :course_simulations, :course_detail_id
  end
end
