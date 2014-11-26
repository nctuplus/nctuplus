class AdminController < ApplicationController
	def ee104
		if request.format=="json"
			all_id=TempCourseSimulation.uniq.order("student_id").pluck(:student_id)
			@users=User.includes(:course_simulations, :course_maps).where(:student_id=>all_id)
			@cm=CourseMap.find(10)
			res=@users.map{|user|{
				:student_id=>user.student_id,
				:courses=>user.courses_json
			}}
		end
		respond_to do |format|
			format.html{}
			format.json{render json:{:users=>res}}
		end
	end
	
end
