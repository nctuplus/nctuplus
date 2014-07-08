module CourseHelper
	def has_rated(ctr_id)
		return !current_user || (current_user && EachCourseTeacherRating.where(:course_teacher_rating_id=>ctr_id, :user_id=>current_user.id).take) ? "true":"false"
	end
end
