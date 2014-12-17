class AdminController < ApplicationController
	include CourseMapsHelper
	
	def ee104
		if request.format=="json"
			all_id=TempCourseSimulation.uniq.order("student_id").pluck(:student_id)
			@users=User.includes(:course_simulations, :course_maps).where(:student_id=>all_id)
=begin
			@users.each do |user|
				tcss=TempCourseSimulation.where(:student_id=>user.student_id)
				failed=tcss.select{|tcs|tcs.course_detail_id==0}
				success=tcss.select{|tcs|tcs.course_detail_id!=0}
				user.course_simulations.each do |cs|
					if cs.course_detail_id!=0
						tcs=success.select{|tcs|tcs.course_detail_id==cs.course_detail_id}.first
						if tcs
							cs.cos_type=tcs.cos_type
							cs.save!
						end
					else
						tcs=failed.select{|tcs|tcs.memo2==cs.memo2}.first
						if tcs
							cs.cos_type=tcs.cos_type
							cs.save!
						end
					end		
				end
			end
=end

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
