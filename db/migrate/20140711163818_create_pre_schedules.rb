class CreatePreSchedules < ActiveRecord::Migration
  def change
    create_table :pre_schedules do |t|
	  t.integer :owner_id
	  t.integer :course_detail_id
      t.timestamps
    end
	add_index :pre_schedules, :owner_id
	add_index :pre_schedules, :course_detail_id
  end
end
