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
	
	def to_json_for_cm
		data = { :id=> self.id, :record_type=> self.record_type, :grade=>self.grade, :half=>self.half }
		if self.course_id
			data = data.merge({
				:course_id=>self.course.id,
				:course_name=>self.course.ch_name,
				:real_id=>self.course.real_id,
				:credit=>self.course.credit,
				:dep=> self.course.course_details.last.try(:department_ch_name)
			})
		else # is course group
			lead_course = self.course_group.lead_course
			unless lead_course #未選代表課，以第一筆當作暫時代表顯示
				lead_course = self.course_group.course_group_lists.first
			end
			data = data.merge({
				:course_id=>lead_course.try(:id),
				:course_name=>lead_course.try(:ch_name) || "ERR",
				:real_id=>lead_course.real_id,
				:credit=>lead_course.credit,
				:dep=> lead_course.course_details.last.try(:department_ch_name),
				:courses=>[]
			})
			self.course_group.course_group_lists.each do |l|
				next if data[:course_id] == l.course.id # lead course is recoreded above
				data[:courses] << l.to_json_for_course_tree
			end
		end
		return data
	end
	
	#has_one :course
end
