class AdminController < ApplicationController
	#include CourseMapsHelper
	before_filter :checkTopManager,:only=>[:users, :ee104, :change_role, :statistics]
	before_filter :checkCourseMapPermission,:only=>[:course_maps] #:checkTopManager
	
	def course_maps
		@course_maps=CourseMap.all.order('name asc')
    end
	
	def users
		@role_sel=[[ "一般使用者",1 ], ["學校系辦單位",2 ], ["系統管理員", 0]]
		@users=User.includes(:department, :course_maps).page(params[:page]).per(20)#limit(50)
		@course_map = CourseMap.all
		unless request.xhr?
			@data = User.all.joins(:department).group(:ch_name).count
		end	
    end
  
    def change_role
		user = User.find(params[:uid])
		user.role = params[:role].to_i
		user.save!
		
		render :layout=>false, :nothing=> true, :status=>200, :content_type => 'text/html'
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
				:last_sem_id=>Semester::LAST.id,
				:pass_score=>60
			}
		end
		respond_to do |format|
			format.html{}
			format.json{render json:res}
		end

	end
    
  def statistics
    @sta=User.select("created_at").group("DATE_FORMAT((created_at),'%M')").order("date(created_at)").count
    
  end
	
end
