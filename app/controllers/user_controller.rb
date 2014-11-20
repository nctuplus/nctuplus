class UserController < ApplicationController

	include CourseHelper
	include CourseMapsHelper
	
  before_filter :checkTopManager, :only=>[:manage, :permission]
	before_filter :checkLogin, :only=>[:add_course,  :special_list, :select_dept]
  before_filter :checkE3Login, :only=>[:import_course]
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
	def all_courses
		@user=getUserByIdForManager(params[:uid])
		if request.format=="json"
			cs_agree=@user.courses_agreed.map{|cs|{
				:name=>cs.course.ch_name,
				:credit=>cs.course_detail.credit,
				:cos_type=>cs.course_detail.cos_type,
				:cf_name=>cs.course_field ? cs.course_field.name : ""
			}}
			cs_taked=@user.courses_taked.map{|cs|{
				:name=>cs.course.ch_name,
				:cos_type=>cs.course_detail.cos_type,
				:cos_id=>cs.course.id,
				:sem_id=>cs.semester_id,
				:t_id=>cs.teacher.id,
				:t_name=>cs.teacher.name,
				:cf_name=>cs.course_field ? cs.course_field.name : "",
				:credit=>cs.course_detail.credit,
				:temp_cos_id=>cs.course_detail.temp_cos_id,
				:file_count=>cs.course_teachership.file_infos.count.to_s,
				:discuss_count=>cs.course_teachership.discusses.count.to_s,
				:score=>cs.score
				#:pass=>check_passed(cs,@user)
				
			}}
			result={
				:pass_score=>@user.pass_score,
				:last_sem_id=>latest_semester.id,
				:agreed=>cs_agree,
				:taked=>cs_taked
			}
		end
		respond_to do |format|
			format.html{render :layout=>false}
			format.json{render json:result}
		end
	end

	def select_cs_cf
		cs=CourseSimulation.find(params[:cs_id])
		cs.course_field_id=params[:cf_id]
		cs.save!
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	def statistics2
		@user=getUserByIdForManager(params[:uid])
		cm=@user.course_maps.take
		#if cm
		#	update_cs_cfids(cm,@user)
		#end
		if request.format=="json"
			@cs_all=@user.all_courses#.where("semester_id != ?",latest_semester.id)
			ls=latest_semester
			course_map=@user.course_maps.first
			course=@cs_all.order("course_field_id DESC").map{|cs|{
				:name=>cs.course.ch_name,
				:cs_id=>cs.id,
				:course_id=>cs.course.id,
				:cos_type=>cs.course_detail.cos_type,
				#:sem_name=>cs.semester ? cs.semester.name : "",
				:sem_id=>cs.semester_id,
				:brief=>cs.course_detail.brief,
				:credit=>cs.course_detail.credit,
				:cf_id=>cs.course_field_id,
				:score=>cs.semester_id==0 ? cs.memo : cs.semester_id==ls.id ? "修習中" : cs.score
			}}
			#cfg_res=get_cf_course_tree(course_map)
			course_map_res={
				:name=>course_map.name,
				:id=>course_map.id,
				:max_colspan=>course_map.course_fields.where(:field_type=>3).map{|cf|cf.child_cfs.count}.max||2,
				:cfs=>get_cm_tree(course_map)
			}
			res={
				:user_id=>@user.id,
				:pass_score=>@user.pass_score,
				:last_sem_id=>latest_semester.id,
				:user_courses=>course,
				:course_map=>course_map_res
			}
		end
		
		respond_to do |format|
			format.html{render :layout=>false}
			format.json{render json:res}
		end
	end

	def import_course_2
		
	end
	
	def import_course
		if request.post?
			score=params[:course][:score]
			score=score
			agree=[]
			normal=[]
			success=true
			
			score.split("\r\n").each do |s|
				s2=s.split("\t")
				if s2.length>3&&s2[2].match(/[[:digit:]]{5}+/)
					Rails.logger.debug "[debug] "+s2[2]
					if s2[2]!=current_user.student_id
						success=false
						break
					end
				elsif s2.length>5 &&s2[0].match(/[[:digit:]]/)
					#Rails.logger.debug "[debug] "+s2[1]
					if s2[1].match(/[A-Z]{3}[[:digit:]]{4}/)
						#Rails.logger.debug "[debug] "+s2[1]
						agree.append({:real_id=>s2[1], :credit=>s2[3].to_i, :memo=>s2[5]})
					elsif s2[1].include?('.')
						course=course
					elsif s2[1].match(/[[:digit:]]{3}+/)&&s2[2].match(/[[:digit:]]{4}/)
					course={'sem'=>s2[1],'cos_id'=>s2[2], 'score'=>s2[7], 'name'=>s2[4]}
					normal.append(course)
					
					end	
				end 
			end
			if !success
				msg="成績驗證錯誤，請匯入自己的成績，謝謝!"
				redirect_to :action =>"special_list", :msg=>msg
				#return
			end
			course=[]
			@pass_score=current_user.department.degree=='2' ? 70 : 60
			has_added=0
			@success_added=0
			@fail_added=0
			fail_course_name=[]
			@no_pass=0
			@pass=0
			if normal.length>0
				#CourseSimulation.where("user_id = ? AND semester_id != ? ",current_user.id,Semester.last.id).destroy_all
				current_user.course_simulations.destroy_all
			end

			agree.each do |a|
				#Rails.logger.debug "[debug] "+Course.where(:real_id=>a).take.ch_name
				
				course=Course.includes(:course_details).where(:real_id=>a[:real_id]).take
				unless course.nil?
				cd_temp=course.course_details.where(:credit=>a[:credit]).first
				CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>cd_temp.id, :semester_id=>0, :score=>"通過", :memo=>a[:memo])
				end
			end

			normal.each do |n|
				#dept_id=Department.select(:id).where(:ch_name=>n['dept_name']).take
				if n['score']=="通過" || n['score'].to_i>=@pass_score
					@pass+=1
				else
					@no_pass+=1
				end
				sem=n['sem']
				sem=Semester.where(:year=>sem[0..sem.length-2].to_i, :half=>sem[sem.length-1].to_i).take
				if sem
					cds=CourseDetail.where(:semester_id=>sem.id, :temp_cos_id=>n['cos_id']).take
					if cds	
						CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>cds.id, :semester_id=>cds.semester_id, :score=>n['score'])
						@success_added+=1
					else
						#fail_course_name.append()
						@fail_added+=1
					end
				else
					@fail_added+=1
				end
			end
			cm=current_user.course_maps.includes(:course_groups, :course_fields).take
			if cm
				update_cs_cfids(cm,current_user)
			end
			msg="匯入完成! 共新增 #{@success_added} 門課 失敗:#{@fail_added} 通過:#{@pass} 未通過:#{@no_pass}"
			redirect_to :action=>"import_course_2", :msg=>msg
		end
	end
	
	#def select_cf
	#	
	#end
	
	def select_dept
		degree=params[:degree_select].to_i
		grade=params[:grade_select].to_i
		if degree==2
			dept=params[:dept_grad_select].to_i
		else
			dept=params[:dept_under_select].to_i
		end
		current_user.update_attributes(:semester_id=>grade,:department_id=>dept)
		UserCoursemapship.where(:user_id=>current_user.id).destroy_all#.each do |uc|
			#uc.destroy!
		#end
		cm=CourseMap.where(:department_id=>current_user.department_id, :semester_id=>current_user.semester_id).take
		if cm
			UserCoursemapship.create(:course_map_id=>cm.id, :user_id=>current_user.id)
		end
		redirect_to :controller=> "user", :action=>"special_list"
	end
  def manage
    @users=User.includes(:semester, :department, :course_simulations, :course_maps).all#limit(50)
	@top_managers=TopManager.all.pluck(:user_id)
  end
  def select_cm
		
		
		user=User.find(params[:uid])
		#user.course_mapships.destroy_all
		UserCoursemapship.where(:user_id=>params[:uid]).destroy_all
		UserCoursemapship.create(:course_map_id=>params[:cm_id], :user_id=>params[:uid])
		#course_map=CourseMap.find(params[:map_id])
		update_cs_cfids(CourseMap.find(params[:cm_id]),user)
		if request.get?
			redirect_to :back
		else
			render :nothing => true, :status => 200, :content_type => 'text/html'
		end
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
	
  def test_get_cs_cm
  	data1 = get_cm_tree(CourseMap.find(params[:map_id]))
  	user = User.find(params[:user_id])
  	data2 = user.all_courses.map{
  			|cs| 
  			{
  			 :id=> cs.course.id,
  			 :uni_id=> cs.id,
  			 :name=>cs.course.ch_name, 
  			 :credit=>cs.course._credit,
  			 :score=>cs.score,
  			 :sem=>((cs.semester_id==0) ? {:year=>0, :half=>0} : {:year=>cs.semester.year, :half=>cs.semester.half}),
  			 :cf_id=>cs.course_field_id,
  			 :memo=>cs.memo,
  			 :degree=>cs.course.department.degree,
  			}}
  			
  	respond_to do |format|
   	 	format.json { render :layout => false, :text => {:user_info=>{:sem=>{:year=>user.semester.year, :half=>user.semester.half}, :degree=>user.department.degree, :sem_now=>{:year=>103, :half=>1}, :student_id=>user.student_id }, :course_map=>data1, :user_courses=>data2 }.to_json}
    end
  end	
  private

	def _get_course_struct(courses)
		courses.map{|c|{
			:name=>c.ch_name,
			:id=>c.id,
			:credit=>c._credit,
		}}
	end
	def _get_bottom_node(cf)		
  	data={
  		:id=>cf.id,
			:cf_name=>cf.name,
			:credit_need=>cf.credit_need,
			:cf_type=>cf.field_type,
			:courses=>_get_course_struct(cf.courses),#.map{|c|{:name=>c.ch_name, :id=>c.id, :credit=>c.credit}},
			:course_groups=>cf.course_groups.where(:gtype=>0).includes(:courses).map{|cg|{
				:credit=> cg.lead_course._credit,
				:lead_course_name=>cg.lead_course.ch_name,
				:lead_course_id=>cg.lead_course.id,
				:courses=>_get_course_struct(cg.courses)#.map{
			}}
		}
		return data
  end
	
	def _get_middle_node(cf,nodes)		
  	data={
  				:id=>cf.id,
				:cf_name=>cf.name,
				:cf_type=>cf.field_type,
				:field_need=>cf.field_type==3 ? cf.field_need : cf.child_cfs.count,
				:credit_need=>cf.credit_need,
				:child_cf=>nodes
		}
		return data
  end
	
	def get_cf_tree(cf)
		return cf_trace(cf,:_get_bottom_node,:_get_middle_node)
		
	end
	def get_cm_cfs(course_map)
		return course_map.course_fields.includes(:courses, :child_cfs).map{|cf|
			cf.field_type < 3 ? 
				_get_bottom_node(cf) : 
				_get_middle_node(cf,cf.child_cfs.includes(:courses).map{|child_cf|get_cf_tree(child_cf)})
		}
	end
	def get_cm_tree(course_map)
		return course_map.course_fields.includes(:courses, :child_cfs).map{|cf|
			cf.field_type < 3 ? 
				_get_bottom_node(cf) : 
				_get_middle_node(cf,cf.child_cfs.includes(:courses).map{|child_cf|get_cf_tree(child_cf)})
		}

	end
	def check_passed(cs,user)
		return cs.semester_id!=latest_semester.id&&(cs.score=="通過"||cs.score.to_i > user.pass_score)
	end
  def user_params
    params.require(:user).permit(:email)
  end
  
end
