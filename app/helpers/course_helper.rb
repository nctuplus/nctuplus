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
	
	def content_type_to_html(id)
		str = ""
		case id
			when 1 #考試
				str = "[考試]"
			when 2 #作業
				str = "[作業]"
			when 3 #上課
				str= "[上課]"
			when 4 #其他
				str = "[其他]"
		end	
		return str.html_safe
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
	
	def dimension_class(cos_type)
		prefix='dimension-'
		case cos_type
			when "通識"
				prefix<<'world'
			when "歷史"
				prefix<<'history'
			when "群已"
				prefix<<'youandme'
			when "公民"
				prefix<<'civil'
			when "自然"
				prefix<<'nature'
			when "文化"
				prefix<<'culture'
		end
	end
	
	def cos_type_class(cos_type)
		prefix="course-"
		case cos_type
			when "共同必修"
				type="common-required"
			when "共同選修"
				type="common-elective"
			when "通識"
				type='general'
			when "必修"
				type='required'
			when "選修"
				type='elective'
			when "外語"
				type='foreign'
			
		end
		#type=""
		prefix<<type
	end
	
	
	
	
end
