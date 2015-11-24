class AdminController < ApplicationController
	#include CourseMapsHelper
	before_filter :checkTopManager,:only=>[:users, :ee104, :change_role, :discusses,:discuss_verify, :user_statistics]
	before_filter :checkCourseMapPermission,:only=>[:course_maps] #:checkTopManager
	
	def discuss_verify
		status=DiscussVerify.create(:user_id=>current_user.id, :discuss_id=>params[:id], :pass=>params[:pass]).valid?
		render :layout=>false, :nothing=> true, :status=>status ? 200 : 500, :content_type => 'text/html'
	end
	
	def discusses
		@begin_time=Time.new(2015,1,1,0,0,0)
		@end_time=Time.now
		@discusses=Discuss.where("created_at BETWEEN ? AND ?",@begin_time,@end_time).includes(:course_teachership, :user, :course)
	end
	def course_maps
		@course_maps=CourseMap.all.order('name asc')
  end
	
	def users
		@role_sel=[[ "一般使用者",1 ], ["學校系辦單位",2 ], ["系統管理員", 0]]
		if params[:search].nil?
			@users= User.all
		else
			@users = User.ransack(name_cont: params[:search]).result
		end
		@users = @users.includes(:department, :course_maps).page(params[:page]).per(20)
		@course_map = CourseMap.all
		
		# for chart
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
    
  def user_statistics
    @user_stat = DataStatistics.user_signup
    @import_cnt = DataStatistics.import_course_count
    @user_type = DataStatistics.user_signin_protocol # [E3, FB, E3&FB]
    @discuss_stat = [Comment.maximum(:id), Discuss.maximum(:id)]   
  end
	
end
