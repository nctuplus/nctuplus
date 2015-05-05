class CreateAgreedScores < ActiveRecord::Migration
  def change
    create_table :agreed_scores, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
			t.integer :user_id, :default=>0, :null=>false
			t.integer :course_id, :default=>0, :null=>false
			t.integer :course_field_id, :default=>0, :null=>false
			t.string :cos_type, :default=>"", :null=>false
			t.string :score, :default=>"通過", :null=>false
			t.string :memo, :default=>"", :null=>false
    end
		add_index :agreed_scores, :user_id
		add_index :agreed_scores, :course_id

		CourseSimulation.where("semester_id = 0").each do |cs|
			if cs.course_detail_id==0
				course_id=Course.create_from_import_fail(cs.memo2).id
			else
				course_id=cs.course.id
			end
			AgreedScore.create(
				:user_id=>cs.user_id,
				:course_id=>course_id,
				:course_field_id=>cs.course_field_id||0,
				:score=>cs.score||"通過",
				:memo=>cs.memo||"",
				:cos_type=>cs.cos_type||""
			)
		end
		
  end
end
