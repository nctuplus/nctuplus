class Course < ActiveRecord::Base
	belongs_to :grade
	belongs_to :department#, :class_name=>"NewDepartment"
	belongs_to :user

	has_many :course_field_lists
	validates_associated :course_field_lists
	has_many :course_fields, :through=>:course_field_lists
	has_many :course_teacherships, :dependent => :destroy
	validates_associated :course_teacherships
	has_many :course_details, :through=> :course_teacherships#, :source=>course_details
	
	#has_many :teachers, :through => :course_teacherships
	
	has_many :semesters, :through => :course_details

		
	def to_result(semester_name)
    {
			"id" => read_attribute(:id),
			"semester_name" => semester_name,
      "ch_name" => read_attribute(:ch_name),
      "eng_name" => read_attribute(:eng_name),
      "real_id" => read_attribute(:real_id),
			"department_name" => Department.find(read_attribute(:department_id)).ch_name#, # no use	 
    }
  end
	
	#def to_json_for
	
	def to_json_for_stat
		{
			:ct_id=>self.course_teacherships.take.id,
			:name=>self.ch_name,
			:id=>self.id,
			:credit=>self.credit,
			#:dept=>self.department ? self.department.ch_name : "",
			:real_id=>self.real_id,
		}
	end	
	
	def to_chart(latest_semester)
		# take 5, for case if have latest_semester
		sems=self.semesters.order(:id).uniq.last(5).reject{|s|s==latest_semester}		
		row_name = sems.map{|s|s.name}				
		row_id = sems.map{|s| s.id}
		if row_id.length ==5
			row_id.shift
			row_name.shift
		end
		tmp = self.course_details.where(:semester_id=>row_id).order(:semester_id)				
		simu = CourseSimulation.where(:course_detail_id=>tmp.map{|ctd| ctd.id})  		
		res = []
		res_score = []
		show_score = false
		tmp.map{|ctd| {:teacher=>ctd.teacher_name, :cdid=>ctd.id, :num=>ctd.reg_num, :sem=>ctd.semester_id } }
		.group_by{|t| t[:teacher]}.each do |k1, k2|
			tmp_num = [0,0,0,0]
			tmp_score = [{:y=>0,:nums=>1},{:y=>0,:nums=>1},{:y=>0,:nums=>1},{:y=>0,:nums=>1}]
			k2.each do |hash|
				tmp_num[row_id.index(hash[:sem])] = hash[:num].to_i						
				score_sum = 0 
				score_count = 0
				simu.select{|sim| sim.semester_id==hash[:sem]&&sim.course_detail_id==hash[:cdid]}.each do |s|
					if s.try(:score) =~ /[[:digit:]]/ #and s.score.to_i >=60
						score_sum+= s.score.to_i
						score_count+=1
						show_score = true
					end
				end
					#	Rails.logger.debug "[debug] "+@row_name.to_s
				tmp_score[row_id.index(hash[:sem])][:y] = (score_count==0) ? 0 : score_sum/score_count*1.0
				tmp_score[row_id.index(hash[:sem])][:nums] = score_count
			end
			res.push({:name=>k1, :data=>tmp_num})
			res_score.push({:name=>k1, :data=>tmp_score})
		end			
				#Rails.logger.debug "[debug] "+ @res.to_s 

		return {:show_reg=>(res.count > 0),
				:show_score=>show_score,
				:semester_name=>row_name, 
				:reg_data=>res, 
				:score_data=>res_score}
	end
	
	
	#UNRANSACKABLE_ATTRIBUTES = ["ch_name"]

  #def self.ransackable_attributes auth_object = nil
  #  (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  #end
	
end
