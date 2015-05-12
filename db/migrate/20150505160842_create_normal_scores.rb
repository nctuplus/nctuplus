class CreateNormalScores < ActiveRecord::Migration
  def change
    create_table :normal_scores, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
			t.integer :user_id, :default=>0, :null=>false
			t.integer :course_detail_id, :default=>0, :null=>false
			t.integer :course_field_id, :default=>0, :null=>false
			t.string :cos_type, :default=>"", :null=>false
			t.string :score, :default=>"", :null=>false
		end
		add_index :normal_scores, :user_id
		add_index :normal_scores, :course_detail_id
		add_index :normal_scores, :course_field_id
		CourseSimulation.where("semester_id!=0").each do |cs|
			NormalScore.create(
				:user_id=>cs.user_id,
				:course_detail_id=>cs.course_detail_id,
				:course_field_id=>cs.course_field_id,
				:cos_type=>cs.cos_type,
				:score=>cs.score
			)
		end
  end
	
end
