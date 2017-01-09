class CreateUserCourseDetailships < ActiveRecord::Migration
  def change
    create_table :user_favorite_courses do |t|
      t.integer :user_id
      t.integer :course_detail_id

      t.timestamps
    end
  end
end
