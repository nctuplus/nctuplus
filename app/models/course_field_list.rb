class CourseFieldList < ActiveRecord::Base
	belongs_to :course
	belongs_to :user
	belongs_to :course_group
	belongs_to :course_field
	
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
