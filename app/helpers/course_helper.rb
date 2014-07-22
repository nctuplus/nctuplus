module CourseHelper
	#def not_logined
	#	return !current_user
	#end
	def has_rated(ctr_id)
		return  (current_user && EachCourseTeacherRating.where(:course_teacher_rating_id=>ctr_id, :user_id=>current_user.id).take) ? "true":"false"
	end
	def latest_semester
		return Semester.last
	end
	

	def rankTag(rank)
		if rank>=1 and rank<=2
			return "success"
		elsif rank>=3 and rank<=4	
			return "primary"
		else
			return "default"
		end	
			
	end
	
	def rankTagBar(rank)
		if rank>=1 and rank<=2
			return "success"
		elsif rank>=3 and rank<=4
			return "info"
		else
			return "default"
		end	
	end		

	def dimension_color(cos_type)
		case cos_type
			when "通識"
				'#FF91FE'
			when "歷史"
				'#FFC991'
			when "群已"
				'#C7FF91'
			when "公民"
				'#91FFC9'
			when "自然"
				'#91C7FF'
			when "文化"
				'#C991FF'
		end
	end
	
	def cos_type_class(cos_type)
		prefix="course-"
		case cos_type
			when "通識"
				type='common'
			when "必修"
				type='required'
			when "選修"
				type='elective'
			when "外語"
				type='foreign'
		end
		prefix<<type
	end
	
	
	
	
end
