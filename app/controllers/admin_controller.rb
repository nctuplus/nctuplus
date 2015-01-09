class AdminController < ApplicationController
	include CourseMapsHelper
	before_filter :checkTopManager
	def users
    @users=User.includes(:semester, :department, :course_simulations, :course_maps).page(params[:page]).per(20)#limit(50)
  end
	
	def ee104
		if request.format=="json"
			all_id=TempCourseSimulation.uniq.order("student_id").pluck(:student_id)
			@users=User.includes(:course_simulations, :course_maps).where(:student_id=>all_id)
			user_res=@users.map{|user|{
				:student_id=>user.student_id,
				:courses=>{
					:success=>user.courses_json,
					:fail=>user.course_simulations.where('course_detail_id = 0').map{|cs| cs.memo2}
				}
			}}
			@cm=CourseMap.find(10)
			res={
				:users=>user_res,
				:course_map=>get_cm_res(@cm),
				:last_sem_id=>Semester.last.id,
				:pass_score=>60
			}
		end
		respond_to do |format|
			format.html{}
			format.json{render json:res}
		end

	end
	
end
