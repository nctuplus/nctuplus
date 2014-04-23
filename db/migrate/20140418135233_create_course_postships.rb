class CreateCoursePostships < ActiveRecord::Migration
  def change
    create_table :course_postships do |t|
	  t.integer :post_id
	  t.integer :course_id	
      t.timestamps
    end
  end
end
