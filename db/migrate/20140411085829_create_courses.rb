class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
	  t.string :ch_name
	  t.string :eng_name
	  t.integer :grade_id
      t.timestamps
    end
  end
end
