class UserController < ApplicationController
	include UserHelper
	include CourseHelper
	include CourseMapsHelper 

	before_filter :checkLogin, :only=>[:this_sem, :add_course,  :show, :courses, :select_dept,
	             :statistics_table, :edit, :update, :add_user_collection, :upload_share_image, :collections]
  	before_filter :checkDepYear, :only=>[:show]
	layout false, :only => [:statistics_table]#, :all_courses2]


	USER_SHARE_DIR = "public/course_table_shares"

	def this_sem
		@user=getUserByIdForManager(params[:uid])
		render :layout=>false
	end
	
	def get_courses
		@user=getUserByIdForManager(params[:uid])
		#if request.format=="json"
			case params[:type]
				when "list"
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
						#:list_type=>params[:type]
					}
				when "simulation"
					result={
						:use_type=>"delete", #for delete button of your current courses
						:view_type=>"simulation",
						:add_to_cart=>params[:add_to_cart]=='1',
						:courses=>@user.normal_scores.includes(:course_detail).search_by_sem_id(Semester::LAST.id).map{|cs|
							cs.course_detail.to_search_result
						}
					}
				when "course_table"
					semester = Semester.find(params[:sem_id])
					result={
						:courses=>@user.normal_scores.includes(:course_detail).search_by_sem_id(params[:sem_id]).map{|cs|
							cs.course_detail.to_course_table_result
						},
						:semesters=> (@user.year==0) ? [] : Semester.where("year >= ? AND half != 3", @user.year).map{|s| {:id=>s.id, :name=>s.name}},
						:semester_name => semester.name, # for 歷年課表 modal header 
						:hash_share => (current_user.canShare?) ? Hashid.user_share_encode([current_user.id, semester.id]) : nil
					}	
				else
					result={}
			end
		#end
		respond_to do |format|
			format.json{render json:result}
		end
		
	end
	
	def courses
		@user=getUserByIdForManager(params[:uid])
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
			if course_map
				cmship = UserCoursemapship.where(:user_id=>@user.id, :course_map_id=>course_map.id).last	
				update_cs_cfids(course_map,@user) if cmship.need_update==1
				
				course_map_res=	{
					:name=>course_map.department_ch_name+" 入學年度:"+course_map.year.to_s,
					:id=>course_map.id,
					:dept_id=>course_map.department_id,
					:year=>course_map.year,
					:total_credit=>course_map.total_credit,
					:max_colspan=>course_map.course_fields.where(:field_type=>3).map{|cf|cf.child_cfs.count}.max||2,
					:cfs=>course_map.to_tree_json		
				}#get_cm_res(course_map)
			end
			res={
				:user_id=>@user.id,
				:pass_score=>@user.pass_score,
				:last_sem=>Semester::CURRENT.name,
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
			update_cs_cfids(cm,current_user)
		end
			
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

	def edit
		@dept_undergrad=Department.where(:majorable=>true).undergraduate.select(:ch_name, :id)#.map{|d| [d.ch_name,d.id]}
    @dept_grad=Department.where(:majorable=>true).graduate.select(:ch_name, :id)#.map{|d| [d.ch_name,d.id]}
	end


	def update
		
		#current_user.update_attributes(:email=>params[:user][:email].blank? ? current_user.email : params[:user][:email])
		last_dept_id=current_user.department_id
		last_year=current_user.year
		
		if current_user.update(user_params)
			if user_params[:department_id]!=last_dept_id || user_params[:year]!=last_year	
				UserCoursemapship.where(:user_id=>current_user.id).destroy_all
				cm=CourseMap.where(:department_id=>current_user.department_id, :year=>current_user.year).take
				if cm
					UserCoursemapship.create(:course_map_id=>cm.id, :user_id=>current_user.id)
				end
				update_cs_cfids(cm,current_user)
			end		
			if request.xhr?
				render :nothing=>true, :status=>200
			else
			  alertmesg('info','success', "修改成功")
				redirect_to user_path
			end
		else
			if request.xhr?
				render :nothing=>true, :status=>200
			else	
				msg = current_user.errors.messages.map{|k,v| "#{v[0]}" }.join("</br>")
				alertmesg('info','warning', msg.html_safe )
				
				# special notify: email conflict (caused by fb email the same)
				if check_error_is_email?(current_user.errors.messages)
					redirect_to user_edit_path(:error=>"email") 
				else
					redirect_to user_edit_path
				end	
			end
		end
	
	end
	
	def upload_share_image
    hash_number = Hashid.user_share_encode([current_user.id, params[:semester_id].to_i])   
    filename = "#{hash_number}.png"
    path = File.join(USER_SHARE_DIR, filename)
    File.open(path, "wb") { |f| f.write(params[:image].read) }
    render :nothing => true, :status => 200, :content_type => 'text/html'   
  end
	
	# update share_agree and return json hashid
	def update_user_share
	  current_user.update_attribute(:agree_share, params[:data])
	  render :json=>{:hash_share=>Hashid.user_share_encode([current_user.id, params[:sem_id].to_i])}
	end
	
	def user_collection_action
	  result = Hashid.user_share_decode(params[:item])
	  if result
	    if params[:type]=="delete_collection"
	      current_user.user_collections.where(:target_id=>result[0], :semester_id=>result[1]).try(:destroy_all)
	    elsif params[:type]=="add_collection"
	      target_user = User.find(result[0])
	      UserCollection.create(:user_id=>current_user.id, :target_id=>target_user.id, :semester_id=>result[1], :name=>target_user.name)    
	    elsif params[:type]=="edit_collection"    
        target = current_user.user_collections.where(:target_id=>result[0], :semester_id=>result[1]).take
        target.update_attributes!(:name=>params[:name]) if params[:name].size > 0 and params[:name].size < 16
        alertmesg('info','warning', "更新成功")
	      redirect_to user_collections_path
	      return 
	    end
	  end
	  render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	def share 
		decode_data = Hashid.user_share_decode(params[:id])
		if decode_data
		  @user = User.find(decode_data[0])
		  @semester = Semester.find(decode_data[1])
		  if @user and @semester
		    if not @user.canShare?
		      alertmesg('info','warning', "使用者未開放分享")
		      redirect_to :root
		      return
		    end
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
		  else
		    not_found
		  end
		else
		  not_found
		end

	end
	
	def collections
	  @collections = current_user.user_collections
	end
	
private

	def check_error_is_email?(errors)
		errors.each do |e|
			return true if e[0] == :email
		end
		return false
	end

  def user_params
    ret=params.require(:user).permit(:name, :agree_share, :year, :department_id, :email)
		if ret[:email].blank?
			ret.except!(:email)
		end
		return ret
  end
  
end