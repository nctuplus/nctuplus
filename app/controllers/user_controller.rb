class UserController < ApplicationController

	include ApiHelper
	include CourseHelper
	include CourseMapsHelper 


	before_filter :checkLogin, :only=>[:upload_share_image, :all_courses, :this_sem, :add_course,  :show, :select_dept, :statistics_table, :get_courses]
  before_filter :checkE3Login, :only=>[:import_course, :add_course]
	layout false, :only => [:add_course, :statistics_table]#, :all_courses2]

	USER_SHARE_DIR = "public/course_table_shares"
	
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
						cs_taked=@user.courses_taked.map{|cs|cs.to_basic_json}					
					else 						
						cs_taked=@user.courses_taked.search_by_sem_id(params[:sem_id]).map{|cs|cs.to_basic_json}
						cs_agree=[]
					end
					result={
						:pass_score=>@user.pass_score,
						:last_sem_id=>Semester::CURRENT.id,
						:agreed=>cs_agree,
						:taked=>cs_taked,
					}
				when "simulation"
					result={
						:use_type=>"delete", #for delete button of your current courses
						:view_type=>"schedule",
						:courses=>@user.normal_scores.includes(:course_detail).search_by_sem_id(Semester::LAST.id).map{|cs|
							cs.course_detail.to_search_result
						}
					}
				when "course_table"
					semester = Semester.find(params[:sem_id])
					result={
						:courses=>@user.normal_scores.includes(:course_detail).search_by_sem_id(semester.id).map{|cs|
							cs.course_detail.to_course_table_result
						},
						:semester_name => semester.name # for 歷年課表 modal header 
					}	
				else
					result={}
			end
		#end
		respond_to do |format|
			format.json{render json: result}
		end
		
	end
	
	def show
		
		@user=getUserByIdForManager(params[:uid])
		if @user.course_maps.empty?  
			cm=CourseMap.where(:department_id=>@user.department_id, :year=>@user.year).take
			if cm
				@user.user_coursemapships.create(:course_map_id=>cm.id)
				update_cs_cfids(cm,@user)
			end
		end
	end
	
	def all_courses
		@user=getUserByIdForManager(params[:uid])
		render :layout=>false
	end

	def select_cs_cf
		if params[:is_agreed]=="true"
			cs=AgreedScore.find(params[:cs_id])
		else
			cs=NormalScore.find(params[:cs_id])
		end
		cs.update_attributes(:course_field_id=>params[:cf_id])
		#cs.save!
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	def statistics		
		@user=getUserByIdForManager(params[:uid])
		if request.format=="json"
			course_map=@user.course_maps.first
			#update_cs_cfids(course_map,@user)
			if course_map
				course_map_res=	{
					:name=>course_map.department_ch_name+" 入學年度:"+course_map.year.to_s,
					:id=>course_map.id,
					:dept_id=>course_map.department_id,
					:year=>course_map.year,
					:max_colspan=>course_map.course_fields.where(:field_type=>3).map{|cf|cf.child_cfs.count}.max||2,
					:cfs=>course_map.to_tree_json		
				}#get_cm_res(course_map)
			end
			res={
				:user_id=>@user.id,
				:need_common_check=>@user.is_undergrad?,
				:pass_score=>@user.pass_score,
				:last_sem_id=>Semester::CURRENT.id,
				:user_courses=>@user.courses_json,
				#:user_courses=>@user.normal_scores.to_stat_json,
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
				current_user.normal_scores.destroy_all
				current_user.agreed_scores.destroy_all
			else
				msg="匯入失敗!"
				redirect_to :action=>"import_course_2", :msg=>msg
				return
			end	
			agree.each do |a|
				#Rails.logger.debug "[debug] "+Course.where(:real_id=>a).take.ch_name		
				course=Course.where(:real_id=>a[:real_id]).take
				if course.nil?
					course=Course.create(a)
				end
				AgreedScore.create_form_import(current_user.id,course.id,a)
				@success_added+=1
			end
			@now_taking=0
			normal.each do |n|
				if n['score']=="通過" || n['score'].to_i>=@pass_score
					@pass+=1
				elsif n['score']==""
					@now_taking+=1
				else
					@no_pass+=1
				end
				sem=n['sem']
				sem=Semester.where(:year=>sem[0..sem.length-2].to_i, :half=>sem[sem.length-1].to_i).take
				if sem
					cd=CourseDetail.where(:semester_id=>sem.id, :temp_cos_id=>n['cos_id']).take
					if cd
						NormalScore.create_form_import(current_user.id,cd.id,n)
						@success_added+=1
					else
						@fail_added+=1
					end
				else
					@fail_added+=1
				end
			end		
			cm=current_user.course_maps.includes(:course_groups, :course_fields).take
			update_cs_cfids(cm,current_user)
			msg="匯入完成! 共新增 #{@success_added} 門課 失敗:#{@fail_added} 通過:#{@pass} 未通過:#{@no_pass} 修習中:#{@now_taking}"
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
				data2=user.courses_stat_table_json
				user_info = {
					:year=>user.year, 
					:year_now=>Semester::CURRENT.year,
					:half_now=>Semester::CURRENT.half,
					:degree=>user.degree, 
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
	
 #   session[:cd].delete(cd_id) if session[:cd].present? && session[:cd].include?(cd_id)			
    current_user.normal_scores.create(
      :course_detail_id=>cd.id,
      :score=>'修習中'
    )
		render :text=>cd.to_course_table_result.to_json, :layout=>false
		#redirect_to "/user/get_courses?uid=#{current_user.id}&type=simulation"
	end
	
	def delete_course
	  cd=CourseDetail.find(params[:cd_id])
	  NormalScore.where(:user_id=>current_user.id, :course_detail_id=>cd.id).destroy_all
	  
	  render :text=>cd.to_course_table_result.to_json, :layout=>false
	end

# share course table 	
  def upload_share_image
    if request.post?  # web js lib will send image by post 
			if params[:image] and params[:semester_id] and current_user
				hash_number = User.generate_hash([current_user.id, params[:semester_id].to_i])
				
				filename = "#{hash_number}.png"
				path = File.join(USER_SHARE_DIR, filename)
				File.open(path, "wb") { |f| f.write(params[:image].read) }
			end	
    end
    render :nothing => true, :status => 200, :content_type => 'text/html'
   
  end
  
	def share # public method for share link	    
    if params[:id]
      data = User.find_by_hash_id(params[:id])
      not_found if data.blank?
      @user = data[0]
      @semester = Semester.find(data[1])
      if @user and @user.canShare? and @semester
        @file_name = "#{params[:id]}.png"
        @fb_share_meta = true
        @host = request.host
        respond_to do |format|
          format.html {}
          format.json { render :json => {
              :courses=>@user.normal_scores.includes(:course_detail).search_by_sem_id(@semester.id).map{|cs|
                cs.course_detail.to_course_table_result},
              :semester_name => @semester.name # for 歷年課表 modal header 
            }
          }
        end   
      else# user找不到或id亂打, 未開放share
       not_found
      end
    else
      not_found
    end  

	end
	
	
	def settings # set share or not
		if params[:type]=="share"
			current_user.update_attribute(:agree_share, params[:data])
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
		
	end
	
	
	def share 
		
		if request.post?
			if params[:canvasImage] and params[:semester_id]
				hash_user_id = current_user.encrypt_id
				semester_id = params[:semester_id]
				filename = "#{hash_user_id}_#{semester_id}.png"
				path = File.join(USER_SHARE_DIR, filename)
				File.open(path, "wb") { |f| f.write(params[:canvasImage].read) }
			end	
			render :nothing => true, :status => 200, :content_type => 'text/html'
		else	
			render :layout=>false
		end

	end
	
  private

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def user_params
    params.require(:user).permit(:email)
  end
  
end
