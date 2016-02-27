class CoursesController < ApplicationController


	before_filter :checkLogin, :only=>[:simulation, :add_simulated_course, :del_simu_course]
	
	def index
		@sem_sel=Semester.all.order("id DESC").pluck(:name, :id)
		if params[:custom_search].present?	#if user key in something			
			@q = CourseDetail.search_by_q_and_text(params[:q],params[:custom_search])
		elsif current_user.try(:department_id)#.present?
			@q = CourseDetail.search({:department_id_eq=>current_user.department_id})
			#@q = CourseDetail.search({
			#	:brief_cont_any=>session[:lack_course]["dimension"]
			#})
		else	
			@q = CourseDetail.search(params[:q])
		end
		cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department)
		@cds=cds.page(params[:page]).order("semester_id DESC").order("view_times DESC")
	end
	
	def search_mini	#for course simulation search & result
		if !params[:dimension_search].blank?	#search by 向度 (推薦系統)
			@q= CourseDetail.search({:semester_id_eq=>Semester::LAST.id, :brief_cont_any=>JSON.parse(params[:dimension_search])})
		elsif !params[:timeslot_search].blank? #search by time (推薦系統)
			@q= CourseDetail.search({:cos_type_cont_any=>["通識","外語"], :semester_id_eq=>Semester::LAST.id, :time_cont_any=>JSON.parse(params[:timeslot_search])})
		elsif !params[:custom_search].blank? #search by text
			@q = CourseDetail.search_by_q_and_text(params[:q],params[:custom_search])
		else
			if params[:q].blank?
				@q=CourseDetail.search({:id_in=>[0]})
			else
				@q=CourseDetail.search(params[:q])				
			end
		end
		cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department)
		@result={
			:view_type=>"simulation",
			:use_type=>"add",
			:add_to_cart=>true,
			:courses=>cds.map{|cd|
				cd.to_search_result
			}
		}
		render "courses/search/mini", :layout=>false
	end
	

	

	def export_timetable
		sem_id=params[:sem_id].to_i
		@sem=Semester.find(sem_id)
		cd_ids=current_user.courses_taked.search_by_sem_id(sem_id).map{|ps| ps.course_detail.id}
		@course_details=CourseDetail.where(:id=>cd_ids).order(:time)

		respond_to do |format|
			 format.xls{
			 	response.headers['Content-Type'] = "application/vnd.ms-excel"
			 	response.headers['Content-Disposition'] = " attachment; filename=\"#{@sem.name}.xls\" "	
			 }
		end
	end	
	
	

	
	
	
  def show
		cd=CourseDetail.includes(:course_teachership, :course, :semester, :department).find(params[:id])	
		incViewTime(cd)
		@list_type=[["[考試]",1],["[作業]",2],["[上課]",3],["[其他]",4]]
		@data = {
			:course_id=>cd.course.id.to_s,
			:course_detail_id=>cd.id.to_s,
			:course_teachership_id=>cd.course_teachership.id.to_s,
			:course_name=>cd.course_ch_name,
			:course_teachers=>cd.teacher_name,
			:course_real_id=>cd.course.real_id.to_s,
			:temp_cos_id=>cd.temp_cos_id,
			:year=>cd.semester_year,
			:half=>cd.semester_half,
			:course_credit=>cd.course.credit,
			:open_on_latest=>(cd.course_teachership.course_details.last.semester_id==Semester::LAST.id) ? true : false ,
			:related_cds=>cd.course_teachership.course_details.includes(:semester,:department).order("semester_id DESC"),
			:updated_at=>cd.updated_at
		}
		#render "/course_content/show"
  end
	
  def simulation  
		@degree_sel=[['大學部','3'],['研究所','2'],['大學部共同','0']]
		@dept_sel=Department.searchable.pluck(:ch_name, :id)
		@q=CourseDetail.search({:id_in=>[0]})
  end
	
	def add_to_cart
		cd_id=params[:cd_id].to_i
		cookies.signed[:cd]=JSON.generate([]) if cookies.signed[:cd].nil?
		cd_ids=JSON.parse(cookies.signed[:cd])
		if params[:type]=="add"
			if CourseDetail.where(:id=>cd_id).empty?
				alt_class="warning"
				mesg="查無此門課!"
			else
				if !cd_ids.include?(cd_id)
					cd_ids.append(cd_id)
					cd_ids=CourseDetail.select(:id).where(:id=>cd_ids).order(:time).pluck(:id)
					alt_class="success"
					mesg="新增成功!"
				else
					alt_class="info"
					mesg="您已加入此課程!"		
				end
			end
		else
			if cd_ids.include?(cd_id)
				cd_ids.delete(cd_id) 
				alt_class="success"
				mesg="刪除成功!"
			else
				alt_class="warning"
				mesg="你未加入此課程!"
			end
		end
		cookies.signed[:cd]={
			:value=> JSON.generate(cd_ids),
			:expires=> 6.months.from_now
		}
		respond_to do |format|
			format.json {
				render :json => {:class=>alt_class, :text=>mesg}
			}
		end
	end
	

	
	def show_cart
		cookies.signed[:cd]=JSON.generate([]) if cookies.signed[:cd].nil?
		@result={
			:view_type=>params[:view_type],
			:use_type=>params[:use_type],#"delete",
			:add_to_cart=>params[:add_to_cart]=='1',
			:courses=>CourseDetail.where(:id=>JSON.parse(cookies.signed[:cd])).map{|cd|
				cd.to_search_result
			}
		}
		render :layout=>false
	end
		
  
  private

	def incViewTime(cd)
		current_time = Time.new
		c_id=cd.id.to_s
		session[:course]={} if session[:course].nil?
		if session[:course][c_id] != current_time.day
			session[:course][c_id] = current_time.day
			cd.incViewTimes!
		end
	end
	
  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
  
end
