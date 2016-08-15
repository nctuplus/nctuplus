class AdminController < ApplicationController
	#include CourseMapsHelper
	before_filter :checkTopManager,:only=>[:users, :ee104, :change_role, :change_dept, :discusses,:discuss_verify, :user_statistics]
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
		if current_user.role==2
			@course_maps=CourseMap.where(:user_id=>current_user.id)
		elsif current_user.role==0
			@user_sel=User.select(:name, :id).where(:role=>[0,2])
			@course_maps=CourseMap.all.order('name asc')
		end
  end
	
	def users
		@role_sel=[[ "一般使用者",1 ], ["學校系辦單位",2 ], ["系統管理員", 0]]
		if params[:search].nil?
			@users= User.all
		else
      user_ids = [AuthFacebook.ransack(:name_cont=>params[:search]).result.pluck(:user_id), 
                  AuthE3.ransack(:student_id_cont=>params[:search]).result.pluck(:user_id),
                  AuthGoogle.ransack(:name_cont=>params[:search]).result.pluck(:user_id)].flatten                                  
			@users = User.where(:id=>user_ids)
		end
		@users = @users.includes(:department, :course_maps).page(params[:page]).per(20)
		@course_map = CourseMap.all
		@dept_sels=Department.select(:ch_name, :id).where(:majorable=>true)
		# for chart
		unless request.xhr?
			@data = User.all.joins(:department).group(:ch_name).count
		end	
  end
  
  def change_role
		render :nothing=> true, :status=>User.find(params[:uid]).update(:role => params[:role].to_i) ? 200 : 500
	end
	
	def change_dept
		render :nothing=> true, :status=>User.find(params[:uid]).update(:department_id => params[:dept_id].to_i) ? 200 : 500
	end
	
	def ee105
=begin
		NormalScore.all.includes(:course_detail).each do |n|
			n.destroy if n.course_detail.nil?
		end
		146565
=end		
		if request.format=="json"
			year=101
			department_id=272
			@users=User.includes(:auth_e3,:agreed_scores,:normal_scores).where(:year=>year,:department_id=>department_id).reject{|user|user.auth_e3.nil?}
			user_res=@users.map{|user|{
				:student_id=>user.auth_e3.student_id,
				:courses=>{
					:success=>user.courses_json,
				}
			}}
			@cm=CourseMap.where(:year=>year,:department_id=>department_id).take
			res={
				:users=>user_res,
				:course_map=>@cm.to_public_json,#get_cm_res(@cm),
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
    @user_stat = DataStatistics.user_signup
    @import_cnt = DataStatistics.import_course_count
    @user_type = DataStatistics.user_signin_protocol # [E3, FB, Google, E3&FB, E3&Google, E3&FB&Google]
    @discuss_stat = [Comment.maximum(:id), Discuss.maximum(:id)]   
    
    @book_new = BookTradeInfo.pluck('DATE_FORMAT(created_at, "%Y/%c")')
                .group_by(&:capitalize).map {|k,v| [k, v.length]}
    @book_sale = BookTradeInfo.where(:status=>1).pluck('DATE_FORMAT(updated_at, "%Y/%c")')     
                .group_by(&:capitalize).map {|k,v| [k, v.length]}

  end
	
end
