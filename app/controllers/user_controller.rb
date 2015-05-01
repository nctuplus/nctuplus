class UserController < ApplicationController

	include ApiHelper
	include CourseHelper
	include CourseMapsHelper 


	before_filter :checkLogin, :only=>[:this_sem, :add_course,  :show, :select_dept, :statistics_table]
  before_filter :checkE3Login, :only=>[:import_course, :add_course]
	layout false, :only => [:add_course, :statistics_table]#, :all_courses2]

	def this_sem
		@user=getUserByIdForManager(params[:uid])
		render :layout=>false
	end
	
	def get_courses
		@user=getUserByIdForManager(params[:uid])
		#if request.format=="json"
			case params[:type]
				when "stat"
					if params[:sem_id].blank?
						cs_agree=@user.courses_agreed.map{|cs|cs.to_basic_json}
						#cs_taked=convert_to_json(@user.courses_taked)
						cs_taked=@user.courses_taked.map{|cs|cs.to_advance_json}
					else 
						cs_taked=@user.all_courses.where(:semester_id=>params[:sem_id]).map{|cs|cs.to_advance_json}#convert_to_json(@user.all_courses.where(:semester_id=>params[:sem_id]))
						cs_agree=[]
					end
					result={
						:pass_score=>@user.pass_score,
						:last_sem_id=>Semester::CURRENT.id,
						:agreed=>cs_agree,
						:taked=>cs_taked,
						#:list_type=>params[:type]
					}
				when "simulation"
					result={
						:use_type=>"delete", #for delete button of your current courses
						:view_type=>"schedule",
						:courses=>@user.course_simulations.includes(:course_detail).where(:semester_id=>Semester::LAST.id).map{|cs|
							cs.course_detail.to_search_result
						}
					}
				when "course_table"
					semester = Semester.find(params[:sem_id])
					result={
						:semester_info=>{	
							:isNow=> (semester.id == Semester::LAST.id),
							:semester_id=> semester.id,
							:semester_name=> semester.name 
						},
						:courses=>@user.course_simulations.includes(:course_detail).where(:semester_id=>semester.id).map{|cs|
							cs.course_detail.to_course_table_result
						}
					}	
				else
					result={}
			end
		#end
		respond_to do |format|
			format.json{render json:result}
		end
		
	end
	
	def show
		
		@user=getUserByIdForManager(params[:uid])
		if @user.course_maps.empty?  
			cm=CourseMap.where(:department_id=>@user.department_id, :year=>@user.year).take
			if cm
				@user.user_course_mapships.create(:course_map_id=>cm.id)
				if !@user.course_simulations.empty?
					update_cs_cfids(cm,@user)
				end
			end
		end
	end
	
	def all_courses
		@user=getUserByIdForManager(params[:uid])
		render :layout=>false
	end

	def select_cs_cf
		cs=CourseSimulation.find(params[:cs_id])
		cs.course_field_id=params[:cf_id]
		cs.save!
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	def statistics
		@user=getUserByIdForManager(params[:uid])
		if request.format=="json"
			course_map=@user.course_maps.first
			#update_cs_cfids(course_map,@user)
			if course_map
				course_map_res=	{
					:name=>course_map.department.ch_name+" 入學年度:"+course_map.year.to_s,
					:id=>course_map.id,
					:dept_id=>course_map.department_id,
					#:sem_id=>course_map.semester_id,
					:max_colspan=>course_map.course_fields.where(:field_type=>3).map{|cf|cf.child_cfs.count}.max||2,
					:cfs=>course_map.to_tree_json		
				}#get_cm_res(course_map)
			end
			res={
				:user_id=>@user.id,
				:pass_score=>@user.pass_score,
				:last_sem_id=>Semester::CURRENT.id,
				:user_courses=>{
					:success=>@user.courses_json,
					:fail=>@user.course_simulations.where('course_detail_id = 0').map{|cs| cs.memo2}
				},
				:course_map=>course_map_res||nil,
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
			if params[:user_agreement].to_i == 0
				redirect_to :root_url
				return
			else
				current_user.agree = (params[:user_agreement].to_i==1) ? true : false 
				current_user.save!
			end
			score=params[:course][:score]
			res=parse_scores(score)
			agree=res[:agreed]
			normal=res[:taked]
			student_id=res[:student_id]
			student_name=res[:student_name]
			dept=res[:dept]
			
			if student_id!=current_user.student_id
				msg="成績驗證錯誤，請匯入自己的成績，謝謝!"
				redirect_to :action =>"show", :msg=>msg
				return
			end

			@pass_score=current_user.pass_score
			has_added=0
			@success_added=0
			@fail_added=0
			fail_course_name=[]
			@no_pass=0
			@pass=0
			if normal.length>0
				#CourseSimulation.where("user_id = ? AND semester_id != ? ",current_user.id,Semester.last.id).destroy_all
				current_user.course_simulations.destroy_all
			
			else
				msg="匯入失敗!"
				redirect_to :action=>"import_course_2", :msg=>msg
				return
			end
			tcss=TempCourseSimulation.where(:student_id=>current_user.student_id)
			
			if !tcss.empty? # from temp
				tcss.each do |tcs|
					tcs.has_added=1
					tcs.save!
					CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>tcs.course_detail_id, :semester_id=>tcs.semester_id, 
											:course_field_id=>0, :score=>tcs.score, :memo=>tcs.memo, :memo2=>tcs.memo2, :cos_type=>tcs.cos_type)
					if tcs.score=="通過" || tcs.score.to_i>=@pass_score
						@pass+=1
					else
						@no_pass+=1
					end
				end
				@success_added=tcss.select{|tcs|tcs.course_detail_id!=0}.length
				@fail_added=tcss.select{|tcs|tcs.course_detail_id==0}.length
			
			else # from user import	
			
				agree.each do |a|
					#Rails.logger.debug "[debug] "+Course.where(:real_id=>a).take.ch_name		
					course=Course.where(:real_id=>a[:real_id]).take
					if !course.nil?
						cd_temp=course.course_details.take#.where(:credit=>a[:credit]).first
						CourseSimulation.create(
							:user_id=>current_user.id,
							:course_detail_id=>cd_temp.id,
							:semester_id=>0,
							:score=>"通過",
							:memo=>a[:memo],
							:import_fail=>0,
							:cos_type=>a[:cos_type]
						)
						@success_added+=1
					else
						CourseSimulation.create(:user_id=>current_user.id, :course_detail_id=>0, :semester_id=>0, :score=>"通過",
												:memo=>a[:memo], :memo2=>a[:real_id]+"/"+a[:credit].to_s+"/"+a[:name], :import_fail=>1, :cos_type=>a[:cos_type])
						@fail_added+=1
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
							CourseSimulation.create(
								:user_id=>current_user.id,
								:course_detail_id=>cds.id,
								:semester_id=>cds.semester_id,
								:score=>n['score'],
								:course_field_id=>0,
								:cos_type=>n['cos_type']
							)
							@success_added+=1
						else
							#fail_course_name.append()
							@fail_added+=1
						end
					else
						@fail_added+=1
					end
				end
			end
			
			cm=current_user.course_maps.includes(:course_groups, :course_fields).take
			#if cm
			update_cs_cfids(cm,current_user)
			#end
			msg="匯入完成! 共新增 #{@success_added} 門課 失敗:#{@fail_added} 通過:#{@pass} 未通過:#{@no_pass}"
			redirect_to :action=>"import_course_2", :msg=>msg
		end
	end

	
	def select_dept
		degree=params[:degree_select].to_i
		grade=params[:grade_select].to_i
		if degree==2
			dept=params[:dept_grad_select].to_i
		else
			dept=params[:dept_under_select].to_i
		end
		current_user.update_attributes(:year=>grade,:department_id=>dept)
		
		UserCoursemapship.where(:user_id=>current_user.id).destroy_all
		
		cm=CourseMap.where(:department_id=>current_user.department_id, :year=>grade).take
		if cm
			UserCoursemapship.create(:course_map_id=>cm.id, :user_id=>current_user.id)
		end
		update_cs_cfids(cm,current_user)
		
		redirect_to :controller=> "user", :action=>"show"
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

  
  def statistics_table
		if request.xhr? 				
			user = (params[:user_id].presence and checkTopManagerNoReDirect) ? getUserByIdForManager(params[:user_id]) : current_user
			course_map = user.course_maps.last 
			data1 = (course_map.presence) ? course_map.to_tree_json : nil
			if data1.presence
				data2 = user.all_courses.map{|cs|{
					:id=> cs.course.id,
					:uni_id=> cs.id,
					:name=>cs.course.ch_name, 
					:credit=>cs.course.credit,
					:score=>cs.score,
					:cos_type=>cs.course_detail.cos_type,
					:sem=>((cs.semester_id==0) ? {:year=>0, :half=>0} : {:year=>cs.semester.year, :half=>cs.semester.half}),
					:cf_id=>cs.course_field_id,
					:memo=>cs.memo||"",
					:degree=>cs.course.department.degree,
				}}
				# if has course_map, user must have semester, dept
				user_info = {
					:year=>user.year, 
					:year_now=>Semester::CURRENT.year,
					:half_now=>Semester::CURRENT.half,
					:degree=>user.department.degree, 
					:map_name=>course_map.name,
					:student_id=>user.student_id 
				}
			else
				data2 = nil
				user_info = nil
			end
		end
		
		respond_to do |format|
			format.html { }
			format.json { render :text => {:user_info=>user_info, :course_map=>data1, :user_courses=>data2 }.to_json}
		end
	end
  
	def add_course
		cd_id=params[:cd_id].to_i
		cd=CourseDetail.find(cd_id)
		_type=params[:type]
		
		if _type=="add"
			session[:cd].delete(cd_id) if session[:cd].include?(cd_id)			
			current_user.course_simulations.create(
				#:user_id=>current_user.id,
				:semester_id=>cd.semester_id,
				:course_detail_id=>cd.id,
				:score=>'修習中'
			)
		else # delete
			CourseSimulation.where(:user_id=>current_user.id, :course_detail_id=>cd.id).destroy_all
			
		end
		redirect_to "/user/get_courses?uid=#{current_user.id}&type=simulation"
	end
	
  private

  def user_params
    params.require(:user).permit(:email)
  end
  
end
