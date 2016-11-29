class CreateUserCourseDetailships < ActiveRecord::Migration
  def change
    create_table :user_course_detailships do |t|
      t.integer :user_id
      t.integer :course_detail_id

      t.timestamps
    end
  end
end
