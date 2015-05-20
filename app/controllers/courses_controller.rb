class CoursesController < ApplicationController
  #before_filter :find_department, :only=>[ :index, :new, :edit]
  
	#include CourseHelper

	before_filter :checkE3Login, :only=>[:simulation, :add_simulated_course, :del_simu_course]
	
	def index_new
		@cds=CourseDetail.limit(10)
	end
	
	def index
		@sem_sel=Semester.all.order("id DESC").pluck(:name, :id)
		@degree_sel=[['大學部','3'],['研究所','2'],['大學部共同','0']]
		@dept_sel=Department.searchable.pluck(:ch_name, :id)
		if !params[:custom_search].blank?	#if user key in something
			@q = CourseDetail.searchByText(params[:custom_search],params[:q] ? params[:q][:semester_id_eq] : "")
		else
			@q = CourseDetail.search(params[:q])		
		end
		cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department, :past_exams, :discusses)
		@cds=cds.page(params[:page]).order("semester_id DESC").order("view_times DESC")
	end
	
	def search_mini	#for course simulation search & result
		
		@degree_sel=[['大學部','3'],['研究所','2'],['大學部共同','0']]
		@dept_sel=Department.searchable.pluck(:ch_name, :id)
		if !params[:dimension_search].blank?	#search by 向度 (推薦系統)
			@q= CourseDetail.search({:semester_id_eq=>Semester::LAST.id, :brief_cont_any=>JSON.parse(params[:dimension_search])})
		elsif !params[:timeslot_search].blank? #search by time (推薦系統)
			@q= CourseDetail.search({:cos_type_cont_any=>["通識","外語"], :semester_id_eq=>Semester::LAST.id, :time_cont_any=>JSON.parse(params[:timeslot_search])})
		elsif !params[:custom_search].blank? #search by text
			@q = CourseDetail.searchByText(params[:custom_search],Semester::LAST.id)
		else
			if params[:q].blank?
				@q=CourseDetail.search({:id_in=>[0]})
			else
				@q=CourseDetail.search(params[:q])				
			end
		end
		cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department)
		@result={
			:view_type=>"schedule",
			:use_type=>"add",
			:courses=>cds.map{|cd|
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
		cd=CourseDetail.find(params[:id])	
		current_time = Time.new
		c_id=cd.course.id.to_s
		if session[c_id] != current_time.min
			session[c_id] = current_time.min
			cd.incViewTimes!
		end
		@list_type=[["[考試]",1],["[作業]",2],["[上課]",3],["[其他]",4]]
		@data = {
			:course_id=>cd.course.id.to_s,
			:course_detail_id=>cd.id.to_s,
			:course_teachership_id=>cd.course_teachership.id.to_s,
			:course_name=>cd.course_ch_name,
			:course_teachers=>cd.teacher_name,
			:course_real_id=>cd.course.real_id.to_s,
			:course_credit=>cd.course.credit,
			:open_on_latest=>(cd.course_teachership.course_details.last.semester_id==Semester::LAST.id) ? true : false ,
			:related_cds=>cd.course_teachership.course_details.includes(:semester,:department).order("semester_id DESC")
		}
		#render "/course_content/show"
  end
	
  def simulation  
		#@user_sem_ids=current_user.course_simulations.map{|cs|cs.semester_id}
		#@user_sem_ids.append(Semester::LAST.id)	
  end
	
	def add_to_cart
		
		if params[:type]=="add"
			cd_id=params[:cd_id].to_i
			session[:cd]=[] if session[:cd].nil?
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
			format.json {
				render :json => {:class=>alt_class, :text=>mesg}
			}
		end
	end
	

	
	def show_cart
		@result={
			:view_type=>"session",
			:use_type=>"delete",
			:courses=>CourseDetail.where(:id=>session[:cd]).map{|cd|
				cd.to_search_result
			}
		}
		render :layout=>false
	end
		
  
  private

  def course_param
		params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end
  
  
end
