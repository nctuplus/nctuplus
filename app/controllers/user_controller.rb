class UserController < ApplicationController
	include CourseHelper
  before_filter :checkTopManager, :only=>[:manage, :permission]
	before_filter :checkLogin, :only=>[:add_course, :import_course, :special_list]
  layout false, :only => [:add_course]
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
	
	def special_list
		ls=latest_semester
		cs_all=current_user.course_simulations
		cs_this=cs_all.select{|cs|cs.semester_id==ls.id}
		cd_this_ids = cs_this.map{|cs|cs.course_detail_id}
		cd_all_ids = cs_all.map{|cs|cs.course_detail_id}
		#cd_ids = CourseSimulation.select(:course_detail_id).where(:user_id=>current_user.id, :semester_id=>latest_semester.id)
		@cd_this=CourseDetail.includes(:course_teachership, :semester).where(:id=>cd_this_ids).order(:cos_type).references(:course_teachership, :semester)
		@cd_this_mixed=get_mixed_info(@cd_this)
		
		
		@cd_all=CourseDetail.includes(:course_teachership, :semester).where(:id=>cd_all_ids).order(:cos_type).references(:course_teachership, :semester)
		@cd_all_mixed=get_mixed_info(@cd_all)
		
		@cd_all_sum=@cd_all.sum(:credit).round
		@cd_all_cos_type_credit=CourseDetail.where(:id=>cd_all_ids).group(:cos_type).sum(:credit)
		
		@cd_all_sem=CourseDetail.includes(:course_teachership, :semester).where(:id=>cd_all_ids).order(:semester_id).references(:course_teachership, :semester)
		@cd_all_sem_mixed=get_mixed_info(@cd_all_sem)
		
		
		#Department.where(:dept_type=>"dept", :degree=>"3").each do |d|
		#	d.update_attributes(:credit=>128)
		#end
		
	end
	
	def test
		
	end
	
	def add_course
		score=params[:course][:score]
		@score=score
		@agree=[]
		@normal=[]
		@score.split("\n").each do |s|
			s2=s.split(" ") 
			if s2.length>5 &&s2[0].match(/[[:digit:]]/)
			
				if s2[1].match(/[A-Z]{3}[[:digit:]]{2}+/)
					@agree.append(s2[1])
				else
				course={'sem'=>s2[1],'cos_id'=>s2[2], 'score'=>s2[7]}
				@normal.append(course)
				end	
			end 
		end
		@course=[]
		pass_score=current_user.department.degree=='2' ? 70 : 60
		@has_added=0
		@success_added=0
		@fail_added=0
		@normal.each do |n|
			#dept_id=Department.select(:id).where(:ch_name=>n['dept_name']).take
			if n['score']=="通過" || n['score'].to_i>=pass_score
				sem=n['sem']
				@sem=Semester.where(:year=>sem[0..sem.length-2], :half=>sem[sem.length-1]).take
				if @sem
					cds=CourseDetail.where(:semester_id=>@sem.id, :temp_cos_id=>n['cos_id']).take
					#@course.append(cds)
					if cds
						if CourseSimulation.where(:user_id=>current_user.id, :course_detail_id=>cds.id, :semester_id=>cds.semester_id).take
							@has_added+=1
						else
							CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>cds.id, :semester_id=>cds.semester_id)
							@success_added+=1
						end
					else
						@fail_added+=1
					end
				else
					@fail_added+=1
				end
			end
		end
		#respond_to do |format|
		#	format.html { redirect_to "user/special_list", :notice => "Successfully created place" }
		#	format.js

		#end
		redirect_to :action =>"special_list", :import_course=>true, :success=>@success_added, :same=>@has_added, :failed=>@fail_added
	end
	
	
	def select_dept
		degree=params[:degree_select].to_i
		if degree==2
			grade=params[:grade_grad_select].to_i
			dept=params[:dept_grad_select].to_i
		else
			grade=params[:grade_under_select].to_i
			dept=params[:dept_under_select].to_i
		end
		current_user.update_attributes(:grade_id=>grade,:department_id=>dept)
		redirect_to :controller=> "user", :action=>"special_list"
	end
  def manage
    @users=User.all
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
  
  def registry
    
    @user=User.new
	render :layout => false
  end

	
  # def create
		# if request.post?
			# _email=params[:user][:email]
			# if User.where(:email=>_email).empty?
				# @user=current_user
			# @user.email=_email
			# @user.activate_token=Digest::SHA1.hexdigest @user.uid
			# @user.grade_id=5
			# @user.activated=0
			# @user.save!
			# @message="新增成功! 管理員將在之後寄出認證信!"
			# else
			# @message="Oops!您的Email已經有人使用囉!"<<current_user.name
			# end
			# flash[:notice] = @message	
		# end
	# redirect_to root_url
  # end
  
  private
  def user_params
    params.require(:user).permit(:email)
  end
  
end
