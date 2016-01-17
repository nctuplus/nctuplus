class CourseGroup < ActiveRecord::Base
	belongs_to :user
	belongs_to :course
	belongs_to :course_map
	belongs_to :course_field_list
	has_many :course_group_lists, :dependent => :destroy
	has_many :courses, :through => :course_group_lists
	has_one :lead_group_list,->{where lead:1}, :class_name=>"CourseGroupList"#, :conditions=>['course_group_lists.lead=1']
	has_one :lead_course, :through => :lead_group_list, :source=>:course
	
	def courses_to_json
		
		
		self.courses.map{|c|
			#_get_course_struct(c)
			c.to_json_for_stat
		}
		
		
	end

### new react version	

	# get only the node itself
	# input boolean value determine with or without course group lists  
	def get_info_for_cm(include_course = true)
		data = {
			:id=>self.id,
			:text=>self.lead_course.try(:ch_name) || "未選代表課",
			:gtype=>self.gtype
		}
		if include_course
			data[:courses] = self.course_group_lists.includes(:course).map{|cgl| cgl.to_json_for_course_group_tree}
		end
		return data
	end
	
end