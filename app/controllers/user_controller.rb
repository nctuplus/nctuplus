class UserController < ApplicationController

	include CourseHelper
	include CourseMapsHelper
	
  before_filter :checkTopManager, :only=>[:manage, :permission]
	before_filter :checkLogin, :only=>[:add_course, :import_course, :special_list, :select_dept]
  layout false, :only => [:add_course]#, :all_courses2]
  # def mail_confirm
    # @user=User.where(:activate_token=>params[:key]).first
		# if(@user)
			# case @user.activated
				# when 2
				# @user.activated=3
				# @user.save
				# @message = "認證成功!您可以開始上傳/下載檔案囉!"
			# when 3
					# @message = "您已經認證過囉!"
				# else
				# @message = "認證失敗!"
			# end
		# else
			# @message= "沒有此使用者喔!"
		# end
    # flash[:notice] = @message
		# redirect_to root_url
  # end
	
  # def activate
    
	# @user=User.find(params[:id])
	# if(@user.activated==1)
      # UserMailer.confirm(@user.name,@user.email,@user.activate_token).deliver
	  # @user.activated=2
	  # @user.save
	# end
    # redirect_to "user/manage"
    
  # end
	def select_cf
		#@cf=curren_user.course_simulations.where(:
	end
	def add_top_manager
		
		if TopManager.find_or_create_by_user_id(:user_id=>params[:uid].to_i, :all_users=>1, :all_departments=>1)
			mesg="新增成功!"
		else
			mesg="新增失敗"
		end
		respond_to do |format|
			format.html {
				render :text => mesg,
							 :content_type => 'text/html',
							 :layout => false
			}
		end
	end
	def special_list
		@ls=latest_semester
		@user=getUserByIdForManager(params[:uid])

		@cs_this=@user.course_simulations.includes(:course_detail,:course,:teacher).where("semester_id = ?",@ls.id)#, :course, :teacher)
		

	end
	def all_courses2
		@user=getUserByIdForManager(params[:uid])
		if request.format=="json"
			cs_agree=@user.courses_agreed.map{|cs|{:name=>cs.course.ch_name, :credit=>cs.course_detail.credit, :cos_type=>cs.course_detail.cos_type, :cf_name=>""}}
			cs_taked=@user.all_courses.where("semester_id != 0").map{|cs|{
				:name=>cs.course.ch_name,
				:cos_type=>cs.course_detail.cos_type,
				:cos_id=>cs.course.id,
				:t_id=>cs.teacher.id,
				:t_name=>cs.teacher.name,
				:credit=>cs.course_detail.credit,
				:temp_cos_id=>cs.course_detail.temp_cos_id,
				:file_count=>cs.course_teachership.file_infos.count.to_s,
				:discuss_count=>cs.course_teachership.discusses.count.to_s,
				:pass=>check_passed(cs,@user)
			}}
			result={:agreed=>cs_agree, :taked=>cs_taked}
		end
		respond_to do |format|
			format.html{render :layout=>false}
			format.json{render json:result}
		end
	end
	def all_courses
		@ls=latest_semester
		@user=getUserByIdForManager(params[:uid])
		@cs_agree=@user.courses_agreed#, :course, :teacher)
		@cs_all=@user.all_courses.where("semester_id != 0")#, :course, :teacher)
		
		@cs_all_cos_type=@cs_all.sort_by{|cs|cs.course_detail.cos_type}
		@cs_all_sem=@cs_all.sort_by{|cs|cs.course_detail.semester_id}
		@cs_this=@cs_all.select{|cs|cs.semester_id==@ls.id}
		@pass_score=@user.department&&@user.department.degree=='2' ? 70 : 60
		@cs_all_passed=@cs_all.select{|cs|cs.score=="通過"||cs.score.to_i>=@pass_score}+ @cs_agree

		


		#@test=@user_courses.zip(@course_field_userarr)
		#

		render :layout=>false
	end
	def statistics2
		@user=getUserByIdForManager(params[:uid])
		if request.format=="json"
			@cs_all=@user.all_courses#.where("semester_id != ?",latest_semester.id)
			course=@cs_all.map{|cs|{
				:name=>cs.course.ch_name,
				:cos_type=>cs.course_detail.cos_type,
				:sem_id=>cs.semester_id,
				:brief=>cs.course_detail.brief,
				:credit=>cs.course_detail.credit,
				:score=>cs.score
			}}
			course_map=@user.course_maps.first
			cfg_res=course_map.course_field_groups.includes(:course_fields).map{|cfg|{
				:name=>cfg.name,
				:cf=>cfg.course_fields.map{|cf|{
					:name=>cf.name,
					:courses=>cf.courses.map{|c|{:name=>c.ch_name}}
				}}
			}}
			course_map_res={
				:name=>course_map.name,
				:id=>course_map.id,
				:cfg=>cfg_res
			}
		end
		respond_to do |format|
			format.html{render :layout=>false}
			format.json{render json:{:course=>course, :course_map=>course_map_res}}
		end
	end
	def statistics
		@ls=latest_semester
		@user=getUserByIdForManager(params[:uid])
		@cs_agree=@user.course_simulations.includes(:course_detail,:course,:teacher).where(:semester_id=> 0)#, :course, :teacher)
		@cs_all=@user.course_simulations.includes(:course_detail,:course,:teacher).where("semester_id != 0")#, :course, :teacher)
		
		@cs_all_cos_type=@cs_all.sort_by{|cs|cs.course_detail.cos_type}
		@cs_all_sem=@cs_all.sort_by{|cs|cs.course_detail.semester_id}
		@cs_this=@cs_all.select{|cs|cs.semester_id==@ls.id}
		@pass_score=@user.department&&@user.department.degree=='2' ? 70 : 60
		@cs_all_passed=@cs_all.select{|cs|cs.score=="通過"||cs.score.to_i>=@pass_score}+ @cs_agree
		#@cs_all_passed=@cs_all_passed.append()
		@course_maps=@user.course_maps.includes(:course_field_groups)
		
		@user_courses = @user.pass_courses.map{|c| c.course}
		
		@max_colspan=Array.new(@course_maps.length,0)
		@total_credit=0
		@course_maps.each_with_index do |course_map , i|
			course_field_group=course_map.course_field_groups.includes(:course_fields)
			@total_credit+=course_field_group.map{|cfg|cfg.credit_need}.reduce(:+)
			
			course_field_group.select{|cfg|cfg.group_type==3}.each do |cfg|
			@max_colspan[i]=cfg.course_fields.count > @max_colspan[i] ? cfg.course_fields.count : @max_colspan[i]
			end
		end
		
		
		render :layout=>false
	end
	
	
	def add_course
		score=params[:course][:score]
		@score=score
		@agree=[]
		@normal=[]
		@score.split("\n").each do |s|
			s2=s.split("\t") 
			if s2.length>5 &&s2[0].match(/[[:digit:]]/)
				#Rails.logger.debug "[debug] "+s2[1]
				if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
					#Rails.logger.debug "[debug] "+s2[1]
					@agree.append({:real_id=>s2[1], :credit=>s2[3].to_i})
				elsif s2[1].include?('.')
					course=course
				elsif s2[1].match(/[[:digit:]]{3}+/)&&s2[2].match(/[[:digit:]]{4}/)
				course={'sem'=>s2[1],'cos_id'=>s2[2], 'score'=>s2[7], 'name'=>s2[4]}
				@normal.append(course)
				
				end	
			end 
		end
		@course=[]
		pass_score=current_user.department.degree=='2' ? 70 : 60
		@has_added=0
		@success_added=0
		@fail_added=0
		@fail_course_name=[]
		@no_pass=0
		@pass=0
		if @normal.length>0
			CourseSimulation.where("user_id = ? AND semester_id != ? ",current_user.id,Semester.last.id).destroy_all
		end

		@agree.each do |a|
			#Rails.logger.debug "[debug] "+Course.where(:real_id=>a).take.ch_name
			
			course=Course.includes(:course_details).where(:real_id=>a[:real_id]).take
			unless course.nil?
			cd_temp=course.course_details.where(:credit=>a[:credit]).first
			CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>cd_temp.id, :semester_id=>0, :score=>"通過")
			end
		end

		@normal.each do |n|
			#dept_id=Department.select(:id).where(:ch_name=>n['dept_name']).take
			if n['score']=="通過" || n['score'].to_i>=pass_score
				@pass+=1
			else
				@no_pass+=1
			end
			sem=n['sem']
			@sem=Semester.where(:year=>sem[0..sem.length-2], :half=>sem[sem.length-1]).take
			if @sem
				cds=CourseDetail.where(:semester_id=>@sem.id, :temp_cos_id=>n['cos_id']).take
				if cds	
					CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>cds.id, :semester_id=>cds.semester_id, :score=>n['score'])
					@success_added+=1
				else
					#@fail_course_name.append()
					@fail_added+=1
				end
			else
				@fail_added+=1
			end
		end
		#respond_to do |format|
		#	format.html { redirect_to "user/special_list", :notice => "Successfully created place" }
		#	format.js

		#end
		redirect_to :action =>"special_list", :import_course=>true, :success=>@success_added, :pass=>@pass, :failed=>@fail_added, :no_pass=>@no_pass, :show_static=>true
	end
	
	
	def select_dept
		degree=params[:degree_select].to_i
		grade=params[:grade_select].to_i
		if degree==2
			dept=params[:dept_grad_select].to_i
		else
			dept=params[:dept_under_select].to_i
		end
		current_user.update_attributes(:semester_id=>grade,:department_id=>dept)
		redirect_to :controller=> "user", :action=>"special_list"
	end
  def manage
    @users=User.includes(:semester, :department, :course_simulations, :course_maps).all#limit(50)
	@top_managers=TopManager.all.pluck(:user_id)
  end
  def select_cm_in_manage
		UserCoursemapship.create(:course_map_id=>params[:cm_id], :user_id=>params[:uid])
		#course_map=CourseMap.find(params[:map_id])
		update_cs_cfids(CourseMap.find(params[:cm_id]),User.find(params[:uid]))
		render :nothing => true, :status => 200, :content_type => 'text/html'
  end
  def permission
    @user=User.find_by(params[:id])
	@departments=Department.all
    if request.post?
			CourseManager.destroy_all(:user_id=>@user.id)
			if params[:department]
				params[:department][:checked].each do |key,value|
					@course_manager=CourseManager.new(:user_id=>@user.id)
					@course_manager.department_id=key
					@course_manager.save!
				end
			end
		end
	end
  private
	def check_passed(cs,user)
		return cs.semester_id!=latest_semester.id&&(cs.score=="通過"||cs.score.to_i > user.pass_score)
	end
  def user_params
    params.require(:user).permit(:email)
  end
  
end
