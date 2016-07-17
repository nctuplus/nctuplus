class CourseGroupList < ActiveRecord::Base
	belongs_to :user
	belongs_to :course
	belongs_to :course_group
	#has_one :course
	
	delegate :ch_name, :dept_name, :real_id, :credit, :to=>:course, :prefix=>true
	
	def to_cm_manage_json
		{
			:cgl_id=>self.id, 
			:course_id=>self.course_id ,
			:course_name=>self.course_ch_name,
			:dept_name=>self.course_dept_name,
			:real_id=>self.course_real_id,
			:credit=>self.course_credit,
		}
	end
	
end
