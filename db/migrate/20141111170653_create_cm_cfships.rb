class CreateCmCfships < ActiveRecord::Migration
  def change
    create_table :cm_cfships do |t|
			t.integer :course_map_id
			t.integer :course_field_id
      t.timestamps
    end
		add_index :cm_cfships, :course_map_id
		add_index :cm_cfships, :course_field_id
  end
end
