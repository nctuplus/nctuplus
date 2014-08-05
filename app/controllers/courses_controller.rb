class CoursesController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
	include CourseHelper
  
	layout false, :only => [:course_raider, :list_all_courses, :search_by_keyword, :search_by_dept, :get_user_simulated, :get_user_courses, :get_sem_form, :get_user_statics, :show_cart, :get_compare]

	before_filter :checkLogin, :only=>[ :raider_list_like, :rate_cts, :simulation, :add_simulated_course, :special_list]



### for course_teacher_page_content	


	def course_raider
		Rails.logger.debug "[debug] "+(params[:ct_id].presence|| "nil")
		ct = CourseTeachership.find(params[:ct_id])
		@ct_id = ct.id		
			if params[:type].to_i==1
				@page = CourseContentHead.where(:course_teachership_id => params[:ct_id].to_i).first.presence || nil			
				render "course_content_head"
			elsif params[:type].to_i==2
				@list = CourseContentList.where(:course_teachership_id => params[:ct_id].to_i)
				render "course_content_list"
			elsif params[:type].to_i==3  #3  -> head form
				@head = CourseContentHead.where(:course_teachership_id => params[:ct_id].to_i).first.presence ||
						CourseContentHead.new(:exam_record=>0, :homework_record=>0)	
				render "content_head_form"
			elsif params[:type].to_i==4	#4 -> list form
				@list = CourseContentList.where(:course_teachership_id => params[:ct_id].to_i).presence || nil		
				render "content_list_form"
			else # 5 -> chart		
				@row_name = Array.new
				@row_open = Array.new
				@row_pick = Array.new
				ct.course_details.each do |cd|
					sem_year = Semester.find(cd.semester_id).name
					if latest_semester.name == sem_year 
						sem_year += " (本學期)"
					end	
					@row_name.push(sem_year)
					
					if cd.students_limit.to_i == 9999 # 無上限設為0防scope太大有顯示問題
						@row_open.push(0)
					else
						@row_open.push(cd.students_limit.to_i)
					end		
					@row_pick.push(cd.reg_num.to_i)
				end
				render "course_chart"
			end		
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
	
	def raider_list_like
		if ContentListRank.where(:user_id=>current_user.id, :course_content_list_id=>params[:list_id]).first.presence
			render :nothing => true, :status => 200, :content_type => 'text/html' #已給過評
		else
			@like = ContentListRank.new(:user_id=>current_user.id, :course_content_list_id=>params[:list_id],:rank=>params[:like_type])	
			if @like.save
				render "raider_list_like"
			else
				render :nothing => true, :status => 200, :content_type => 'text/html'
			end				
		end	
	end
	
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
###	
	def index
		#reset_session
		@semesters=Semester.all
		
		if !session[:saved_query]
			session[:saved_query]={}
		end
		
		get_autocomplete_vars

		@semester_select=Semester.all.select{|s|s.courses.count>0}.reverse.map{|s| {"walue"=>s.id, "label"=>s.name}}.to_json
		
		@view_type=""

		
		#render "index_select_ver"
		
  end
	
	def get_user_statics
		@css=current_user.course_simulations
		sem_ids=@css.map{|s|s.semester_id}
		@sems=Semester.where(:id=>sem_ids)
		#@cds=CourseDetail.where(:id=>cd_ids).order(:semester_id)
		@common_courses=@css.select{|cs|cs.course_detail.cos_type=="通識"}.map{|cs|cs.course_detail}
		#@common_courses=CourseDetail.where(:id=>cd_ids)
		render "statics"
	end
	
	def get_sem_form
		@user_sem_ids=current_user.course_simulations.map{|cs|cs.semester_id} 
		render "sem_form"
	end
	def get_user_courses 
		sem_id=params[:sem_id].to_i
		cd_ids=current_user.course_simulations.filter_semester(sem_id).map{|ps| ps.course_detail.id}
		@course_details=CourseDetail.where(:id=>cd_ids).order(:cos_type ,:brief)

		@sem_id=sem_id

		@cd_all=get_mixed_info(@course_details)
		@sem=Semester.find(sem_id)

		#respond_to do |format|
    #  format.html # index.html.erb
    #  format.json { render json: @preschedules.map{|preschedule| preschedule.to_simulated } }
    #end
		if params[:type]=="schd"
			session[:saved_query]={}
			@cd_jsons=@course_details.map{|cd|{"time"=>cd.time,"class"=>cos_type_class(cd.cos_type),"room"=>cd.room,"name"=>cd.course_teachership.course.ch_name}}.to_json
			render "user_schedule"
		elsif params[:type]=="list"
			render "course_lists_mini"
		else 
			render ""
		end
	end
	
	def get_user_simulated
		@sem_id=params[:sem_id].to_i
		get_autocomplete_vars
		@view_type="_mini"
		@table_type="simulated"
		render "srch_and_schd"
	end
	
	
	def add_simulated_course
		cd_id=params[:cd_id].to_i
		_type=params[:type]
		if params[:from]=="cart"
			session[:cd].delete(cd_id)
		end
		sem_id=params[:sem_id]
		if _type=="add"
			CourseSimulation.create(:user_id=>current_user.id, :semester_id=>sem_id, :course_detail_id=>cd_id)
		else
			CourseSimulation.where(:user_id=>current_user.id, :course_detail_id=>cd_id).destroy_all
				
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	def list_all_courses
	  page=params[:page].to_i
		id_begin=(page-1)*each_page_show
		@course_details=CourseDetail.where(:id=>id_begin..id_begin+each_page_show)
		@course_details=@course_details.sort_by{|cd| cd.course_teachership.course_teacher_ratings.sum(:avg_score)}.reverse
		#@course_details=@courses
		@cd_all=get_mixed_info(@course_details)
		@page_numbers=CourseDetail.all.count/each_page_show
	  render "course_lists"
	end
	
	def search_by_dept
		dept_id=params[:dept_id]
		@sem_id=params[:sem_id].to_i
		@sem=Semester.find(@sem_id)
		dept_ids=get_dept_ids(dept_id)
		
		if params[:view_type]!="_mini"
			session[:saved_query]={:type=>"dept",:sem_id=>@sem_id, :dept_id=>dept_id, :degree=>@dept_main.degree}
		end
		
		semester=Semester.where(:id=>@sem_id).take
		if semester
			@courses=semester.courses.select{|c| join_dept(c,dept_ids)}
		
		else
			@courses=Course.where(:department_id=>dept_ids)
			#@course_details=@courses.
		end
		
		@course_details=join_course_detail(@courses,@sem_id)
		#@course_details=@course_details.sort_by{|cd| cd.course_teachership.course_teacher_ratings.sum(:avg_score)}.reverse
		#@courses=Course.where(:id=>@course_details.map{|cd|cd.course_teachership.course_id})
		#@teachers=Teacher.where(:id=>@course_details.map{|cd|cd.course_teachership.teacher_id})		
		#@cd_all=@course_details.zip(@courses,@teachers)
		@cd_all = get_mixed_info(@course_details||[])
		
		@page_numbers=1#@course_details.count/each_page_show
		@table_type="search" if params[:view_type]=="_mini"
		render "course_lists"+params[:view_type]
	end
	
	def search_by_keyword
	  search_term=params[:search_term]
		search_type=params[:search_type]
		semester_id=params[:sem_id].to_i
		dept_id=params[:dept_id].to_i
		degree_id=params[:degree_id].to_i
		
		if params[:view_type]!="_mini"
			session[:saved_query]={:type=>"keyword",:sem_id=>semester_id, :dept_id=>dept_id, :degree=>degree_id, :term=>search_term, :search_type=>search_type}
		end
		if dept_id!=0
			dept_ids= get_dept_ids(dept_id)
		else
			dept_ids=Department.where(:degree=>degree_id).map{|d|d.id} if degree_id!=0
		end
		case search_type
			when "course_time"
				course_ids=[]
				cd_ids=[]
				#@course_details=nil
				search_term.split(' ').each do |st|
					st=st.upcase
					unless semester_id==0
						@cds=CourseDetail.where("semester_id= ? AND time LIKE ?  ",semester_id,"%#{st}%")
					else
						@cds=CourseDetail.where("time LIKE ?  ","%#{st}%")
					end
					ids=@cds.map{|cd|cd.id}
					cd_ids.append(ids) unless ids.empty?
					#course_ids.append(@cd.map{|cd|cd.course_teachership.course.id})
				end
				unless cd_ids.empty?
					@course_details=CourseDetail.where(:id=>cd_ids)
					@course_details=@course_details.select{|cd|join_dept(cd.course_teachership.course,dept_ids)} if dept_ids
				end
				#@courses=Course.where(:id=>course_ids)
				#@courses=@courses.select{|c| join_dept(c,dept_ids) } if dept_ids
				
			when "course_name"
				unless semester_id==0
					@courses = Course.where("id IN (:id) AND ch_name LIKE :name ",
						{:id=>SemesterCourseship.select("course_id").where(:semester_id=> semester_id), :name => "%#{search_term}%" })
				else
					@courses= Course.where("ch_name LIKE :name ",
																{:name => "%#{search_term}%" })#, :id=> SemesterCourseship.select("course_id").where(:semester_id=> "8"))		
				end
				if @courses
					@courses=@courses.select{|c| join_dept(c,dept_ids) } if dept_ids
					@course_details=join_course_detail(@courses,semester_id) unless @courses.empty? 
				end
		end
		
		@cd_all=get_mixed_info(@course_details||[])
		
		@page_numbers=1#@course_details.count/each_page_show
		
		#	render
		#else
		@table_type="search" if params[:view_type]=="_mini"
		render "course_lists"+params[:view_type]
		#end
	end
	
	def rate_cts
    ctr_id=params[:ctr_id].to_i
		score=params[:score].to_i

		@ctr=CourseTeacherRating.find(ctr_id)#:course_teachership_id =>ctr_id, :rating_type=>type).take
		etr=EachCourseTeacherRating.where(:user_id=>current_user.id, :course_teacher_rating_id=>@ctr.id).take
		if score!=0 && !etr
			EachCourseTeacherRating.create(:score=>score, :user_id=>current_user.id, :course_teacher_rating_id=>@ctr.id)
		elsif score==0
			if etr
				etr.destroy!
			end
		end
		total_rating_counts=EachCourseTeacherRating.where(:course_teacher_rating_id=>@ctr.id).count
		total_rating_sum=EachCourseTeacherRating.where(:course_teacher_rating_id=>@ctr.id).sum(:score)
		avg=total_rating_sum.to_f/total_rating_counts
		avg=avg.nan? ? 0 :avg
		@ctr.update_attributes(:total_rating_counts=>total_rating_counts, :avg_score=>avg)
		
		result={:new_score=>@ctr.avg_score, :new_counts=>@ctr.total_rating_counts, :score=>score}
		respond_to do |format|
			format.html {
				render :json => result.to_json,
							 :content_type => 'text/html',
							 :layout => false
			}
		end
	end
	def get_compare
		@course = Course.includes(:course_teacherships).find(params[:c_id])
		@teachers=@course.teachers
		@cts=@course.course_teacherships.includes(:course_teacher_ratings, :course_details)
		#@zz=@cts
		@cts_mix=@cts.zip(@teachers)
		#.sort_by{
		#	|cd| CourseTeachership.where(:course_id=>@course,:teacher_id=>cd.id).first.course_teacher_ratings.sum(:avg_score) 
		#}.reverse
		render "show_compare"
	end
	
	
  def show
		if !session[:cd]
			session[:cd]=[]
		end
    @course = Course.includes(:semesters).find(params[:id])
	 
		@first_show=params[:first_show]||"tc"

		
		#course_details_tids=CourseDetail.where(:course_id=>@course.id).uniq.pluck(:teacher_id)
		
		# for _teacher_info.html.erb
		@teachers=@course.teachers.sort_by{
			|cd| CourseTeachership.where(:course_id=>params[:id],:teacher_id=>cd.id).first.course_teacher_ratings.sum(:avg_score) 
		}.reverse
		if params[:tid]
			@teacher_show =  Teacher.find(params[:tid])
			@target_rank = -1 ;
			@teachers.each_with_index do | teacher, idx|
				if teacher.id == @teacher_show.id
					@target_rank = idx+1
					break 
				end
			end
		else
			@teacher_show =  @teachers.first
			@target_rank = 1 
		end
		@ct=CourseTeachership.includes(:course_details).where(:course_id=>@course.id,:teacher_id=>@teacher_show.id).take
		# course_teacherships.where(:course_id=>params[:id]).course_teacher_ratings
		@sems=@course.semesters

	#@teachers=Teacher.where(:course_id=>@course.id)
	


	#@teachers=Teacher.where(:course_id=>@course.id)
  end
	
	def simulation
    
		@user_sem_ids=current_user.course_simulations.map{|cs|cs.semester_id}
		if @user_sem_ids.empty?
			@user_sem_ids=latest_semester.id
		end
  end
	
  def new
    @course=@department.courses.build
  end
	
  def edit
    @course = Course.find(params[:id])
  end
	
  def update
    @course = Course.find(params[:id])
	
    @course.ch_name=params[:course][:ch_name]
		@course.eng_name=params[:course][:eng_name]
    @course.save!
    redirect_to :action => :show, :id => @course
  end
	
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    redirect_to :action => :index
  end
  

	def add_to_cart
		
		if params[:type]=="add"
			ct_id=CourseTeachership.where(:course_id=>params[:cd_id], :teacher_id=>params[:tid]).take.id
			cd_id=CourseDetail.where(:course_teachership_id=>ct_id, :semester_id=>Semester.last.id).take.id
			
			if !session[:cd].include?(cd_id)
				session[:cd].append(cd_id) 
				alt_class="success"
				title='Success'
				mesg="新增成功!"
			else
				alt_class="success"
				title='Oops'
				mesg="您已加入此課程!"		
			end
		else
			cd_id=params[:cd_id].to_i
			if session[:cd].include?(cd_id)
				session[:cd].delete(cd_id) 
				alt_class="success"
				title='Success'
				mesg="刪除成功!"
			else
				alt_class="success"
				title='Oops'
				mesg="你未加入此課程!"
			end
		end
		
		respond_to do |format|
			format.html {
				render :text => ajax_flash(alt_class,title,mesg),
							 :content_type => 'text/html',
							 :layout => false
			}
		end
		#render :nothing => true, :status => 200, :content_type => 'text/html'

		
	end
	def show_cart
		@sem=latest_semester
		@course_details=CourseDetail.where(:id=>session[:cd])
		@cd_all=get_mixed_info(@course_details)
		@table_type=params[:table_type]
		if params[:sem_id]
			@sem=Semester.find(params[:sem_id])
		end
		render "shopping_cart_list"
	end
	
  protected
  def find_department
    @department=Department.find(params[:department_id])
  end
  
  
  private
	
	def get_mixed_info(cds)
		#courses=Course.join(:course_teachership).where(:id=>cds.map{|cd|cd.course_teachership})
		courses=Course.where(:id=>cds.map{|cd|cd.course_teachership.course_id})
		courses_dulp=cds.map{|cd| courses.select{|c|c.id==cd.course_teachership.course_id}.first}
		teachers=Teacher.where(:id=>cds.map{|cd|cd.course_teachership.teacher_id})
		teachers_dulp=cds.map{|cd| teachers.select{|t|t.id==cd.course_teachership.teacher_id}.first}
		return cds.zip(courses_dulp,teachers_dulp)
	end
	
	
	def get_autocomplete_vars
		@departments=Department.where("dept_type != 'no_courses'")#.merge(Department.where(:dept_type=>'common'))
		@departments_all_select=@departments.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_grad_select=@departments.select{|d|d.degree=='2'}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_under_grad_select=@departments.select{|d|d.degree=='3'}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@departments_common_select=@departments.select{|d|d.degree=='0'||d.degree=="5"}.map{|d| {"walue"=>d.id, "label"=>d.ch_name}}.to_json
		@degree_select=[{"walue"=>'3', "label"=>"大學部[U]"},{"walue"=>'2', "label"=>"研究所[G]"},{"walue"=>'0', "label"=>"大學部共同課程[C]"}].to_json
	end
	def join_course_detail(courses,semester_id)
		course_ids=courses.map{|c| c.id}
		ct_ids=CourseTeachership.where(:course_id=>course_ids)#@courses.map{|c|c.course_teacherships.map{|ct| ct.id}}
		if semester_id!=0
			course_details=CourseDetail.includes(:course_teachership).where(:course_teachership_id=>ct_ids).references(:course_teachership).order(:cos_type ,:brief).flit_semester(semester_id)
		else
			course_details=CourseDetail.includes(:course_teachership).where(:course_teachership_id=>ct_ids).references(:course_teachership)
		end
		return course_details
	end
	
	def get_dept_ids(dept_id)
	  return nil if dept_id==0
		
	  dept_ids=[]
		@dept_main=Department.where(:id=>dept_id).take
		dept_ids.append(@dept_main.id)
		if @dept_main.dept_type=="dept"
			dept_college=Department.where(:degree => @dept_main.degree, :college_id=>@dept_main.college_id, :dept_type => 'college').take
			dept_ids.append(dept_college.id) if !dept_college.nil?
		end
		return dept_ids
	end
	
	def join_dept(course,dept_ids)
		dept_ids.each do |dept_id|
		  return true if course.department_id==dept_id
		end
		return false
	end
	
	def each_page_show
	  30
	end
	
  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
  
end
