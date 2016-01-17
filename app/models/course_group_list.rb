class CourseGroupList < ActiveRecord::Base
	belongs_to :user
	belongs_to :course
	belongs_to :course_group
	#has_one :course
	
	def to_json_for_course_group_tree
		return {
			:id=>self.id,
			:course_id=>self.course_id,
			:course_name=>self.course.ch_name,
			:dep=>self.course.course_details.last.try(:department_ch_name),
			:real_id=>self.course.real_id,
			:credit=>self.course.credit,
			:leader=>(self.lead==0) ? false : true 
		}
	end
	
	def to_json_for_course_tree
		return {
				:id=> self.id,
				:course_id=>self.course_id,
				:course_name=> self.course.ch_name,
				:real_id=> self.course.real_id,
				:credit=> self.course.credit
			}
	end
end
