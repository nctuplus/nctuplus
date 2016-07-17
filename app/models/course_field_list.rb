class CourseFieldList < ActiveRecord::Base
	belongs_to :course
	belongs_to :user
	belongs_to :course_group
	has_many :course_group_lists, :through=> :course_group
	has_many :courses, :through=> :course_group_lists
	has_many :departments, :through=> :courses
	belongs_to :course_field
	
	def to_cm_mange_json
		return {
			:cfl_id=>self.id,
			:record_type=>self.record_type,
			:grade=>self.grade,
			:half=>self.half,
			:course_id=>self.course_id ,
			:course_name=>self.course.ch_name,
			:dept_name=>self.course.dept_name,
			:real_id=>self.course.real_id,
			:credit=>self.course.credit,
		}
	end
	
	def suggest_sem
		_grade={
			"1"=>"大一",
			"2"=>"大二",
			"3"=>"大三",
			"4"=>"大四",
			"*"=>"不限"#,
			#"":""
		}
		_half={
			"1"=>"上",
			"2"=>"下",			
			"3"=>"暑",
			"*"=>"不限"#,
			#"":""
		}
		
		return self.grade=="*" ? "不限" : _grade[self.grade]+_half[self.half]
	end
	
	#has_one :course
end
