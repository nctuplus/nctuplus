module CourseHelper
	def has_rated(ctr_id)
		return !current_user || (current_user && EachCourseTeacherRating.where(:course_teacher_rating_id=>ctr_id, :user_id=>current_user.id).take) ? "true":"false"
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
	
	
end
