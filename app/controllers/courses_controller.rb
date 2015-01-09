class CoursesController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
	include CourseHelper
  
	layout false, :only => [:show_cart, :get_compare]


	before_filter :checkE3Login, :only=>[:simulation, :add_simulated_course, :del_simu_course]
	
	def index
		@cds=custom_search(true,true)
	end
	def search_mini
		@result={
			:view_type=>"schedule",
			:use_type=>"add",
			:courses=>custom_search(!params[:q].blank?,false).map{|cd|
				cd.to_search_result
			}
		}
		render "courses/search/mini", :layout=>false
	end
	def search_mini_cm
		if !params[:q].blank?
			@q = Course.search(params[:q])
		else
			@q = Course.search({:id_eq=>0})	
		end
		
		@courses=@q.result(distinct: true).includes(:course_details).reject{|c|c.course_details.empty?}.sort_by{|c|c.course_details.first.cos_type}
		
		if params[:map_id].presence
			course_group = CourseGroup.where("gtype=0 AND course_map_id=? ",params[:map_id]).map{|cg| cg.id}
			course_group_courses = CourseGroupList.where(:course_group_id=>course_group, :lead=>0).includes(:course).map{|c| c.course}
			@courses = @courses.reject{|course| course_group_courses.include? course }
		end
		render "courses/search/course_map", :layout=>false
	end
	
	
	
	def course_content_post

		if params[:post_type].to_i==0 #head
			@head = CourseContentHead.where(:course_teachership_id=> params[:ct_id]).first.presence || 
							CourseContentHead.new(:course_teachership_id=> params[:ct_id])
			@head.last_user_id = current_user.id
			@head.exam_record = params[:test].to_i
			@head.homework_record = params[:hw].to_i
			@head.course_rollcall = params[:rollcall].to_i
			@head.save!

			render "content_head_update"
		else #list
			tr_id = params[:id][17..-1].to_i
			if params[:id].include?("new") #new
				@list = CourseContentList.new(:course_teachership_id=>params[:ct_id],:user_id=>current_user.id)
				@list.content_type = params[:content_type].to_i
				@list.content = params[:content]
				@list.save!
			else #update old
 				@list = CourseContentList.find(tr_id)
 				if params[:del].to_i==1
 					@list.destroy
 				else	
 					@list.content_type = params[:content_type].to_i
					@list.content = params[:content]
					@list.save!
					if @list.content_list_ranks.presence
						@list.content_list_ranks.destroy_all
					end	
				end
			end
			@trid = params[:id]
			render "content_list_update"
		end
	end
	
	
	
	
	def comment_submit
		@com = Comment.new(:content=>params[:comment], :content_type=>params[:type].to_i)
		@com.user_id = current_user.id
		@com.course_teachership_id = params[:ctship]
		
		if @com.save
			render 'comment_submit'	
		else
			render :nothing => true, :status => 200, :content_type => 'text/html'	
		end
		#render :nothing => true, :status => 200, :content_type => 'text/html'
  	 	
  end

	def timetable
		sem_id=params[:sem_id].to_i
		@sem=Semester.find(sem_id)
		cd_ids=current_user.course_simulations.filter_semester(sem_id).map{|ps| ps.course_detail.id}
		@course_details=CourseDetail.where(:id=>cd_ids).order(:time)

		respond_to do |format|
			 format.xlsx{
			 	response.headers['Content-Type'] = "application/vnd.ms-excel"
			 	response.headers['Content-Disposition'] = " attachment; filename=\"#{@sem.name}.xls\" "	
			 }
		end
	end	
	
	

	def get_compare
		@course = Course.includes(:course_teacherships).find(params[:c_id])

		@cts=@course.course_teacherships.includes(:new_course_teacher_ratings, :course_details)
		@ct_compare_json=[]
		@user_rated_json=[]
		t_name=[]
		@cts.includes(:new_course_teacher_ratings).each do |ct|
			next if t_name.include?(ct.teacher_name)
			t_name.push(ct.teacher_name)
			
			cold_ratings=ct.cold_ratings
			sweety_ratings=ct.sweety_ratings
			hardness_ratings=ct.hardness_ratings
			
			res={
				:id=>ct.id,
				:name=>ct.teacher_name,
				:cold=>cold_ratings,
				:sweety=>sweety_ratings,
				:hardness=>hardness_ratings,
			}
			user_ratings={
				:cold=>!cold_ratings.nil? && !cold_ratings.arr.select{|cr|cr.user_id==current_user.id}.empty? ,
				:sweety=>!sweety_ratings.nil? && !sweety_ratings.arr.select{|cr|cr.user_id==current_user.id}.empty? ,
				:hardness=>!hardness_ratings.nil? && !hardness_ratings.arr.select{|cr|cr.user_id==current_user.id}.empty?
			}
			@ct_compare_json.push(res)
			@user_rated_json.push(user_ratings)
		end
		render "show_compare"
	end
	
	
  def show
		cd=CourseDetail.find(params[:id])
		cd.incViewTimes!

		@ct=cd.course_teachership
		@course = @ct.course#Course.includes(:semesters).find(params[:id])
		@cds=@ct.course_details.includes(:semester,:department)
		zz=@ct.cold_ratings.avg_score
		@first_show=params[:first_show]||"tc"
		@target_rank=999
		@sems=@course.semesters.uniq

  end
	
  def simulation  
		@user_sem_ids=current_user.course_simulations.map{|cs|cs.semester_id}
		@user_sem_ids.append(latest_semester.id)	
  end
	
	def add_to_cart
		
		if params[:type]=="add"
			cd_id=params[:cd_id].to_i
			session[:cd]=[] if !session[:cd]
			if CourseDetail.where(:id=>cd_id).empty?
				alt_class="warning"
				mesg="查無此門課!"
			else
				if !session[:cd].include?(cd_id)
					session[:cd].append(cd_id)
					session[:cd]=CourseDetail.select(:id).where(:id=>session[:cd]).order(:time).pluck(:id)
					alt_class="success"
					mesg="新增成功!"
				else
					alt_class="info"
					mesg="您已加入此課程!"		
				end
			end
		else
			cd_id=params[:cd_id].to_i
			if session[:cd].include?(cd_id)
				session[:cd].delete(cd_id) 
				alt_class="success"
				mesg="刪除成功!"
			else
				alt_class="warning"
				mesg="你未加入此課程!"
			end
		end
		
		respond_to do |format|
			format.html {
				render :text => ajax_flash(alt_class,title,mesg),
							 :content_type => 'text/html',
							 :layout => false
			}
			format.json {
				render :json => {:class=>alt_class, :text=>mesg}
			}
		end
		#render :nothing => true, :status => 200, :content_type => 'text/html'

		
	end
	

	
	def show_cart
		@result={
			:view_type=>"session",
			:use_type=>"delete",
			:courses=>CourseDetail.where(:id=>session[:cd]).map{|cd|
				cd.to_search_result
			}
		}
	end
		
  
  private
	def custom_search(showDefault,pageble)
		if !params[:custom_search].blank?
			@q = CourseDetail.search({:course_ch_name_or_time_or_brief_cont=>params[:custom_search],:semester_id_eq=>params[:q] ? params[:q][:semester_id_eq] : ""})
			cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :file_infos, :discusses)
			if cds.empty? #search teacher
				@q = CourseDetail.search({:by_teacher_name_in=>params[:custom_search],:semester_id_eq=>params[:q] ? params[:q][:semester_id_eq] : ""})		
				cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :file_infos, :discusses)
			end
		else
			if params[:action]=="index"
				@q = CourseDetail.search(params[:q])
			else
				@q=CourseDetail.search({:id_in=>[0]})
			end
			cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :file_infos, :discusses).order("semester_id DESC")
		end
		
		cds=cds.order("view_times DESC")

		return params[:action]=="index" ? cds.page(params[:page]) : cds
	end
  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
  
end
