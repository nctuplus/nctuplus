class AddTableTempCs < ActiveRecord::Migration
  def change
  	create_table :temp_course_simulations, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
			t.string :student_id
			t.string :name
			t.string :dept
			t.integer :semester_id
			t.integer :course_detail_id
			t.integer :course_field_id
			t.string :score
			t.string :memo
			t.timestamps
    end
  end
end
