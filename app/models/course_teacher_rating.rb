class CourseTeacherRating < ApplicationRecord
	def to_json_obj
		{
			:course_teachership_id=>self.course_teachership_id,
			:score=>self.score,
			:user_id=>self.user_id,
			:rating_type=>self.rating_type,
		}
	end
end
